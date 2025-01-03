class LegacyEntityController < ApplicationController
  def index
    token_user = nil : User?

    # Legacy "token" authentication.
    if params[:token]?
      # Timelord uses a version of bcrypt hash that's basically only
      # used by PHP, so we "fix" it to the version Crystal BCrypt
      # uses. This is hackery stuff, but using password hashes in auth
      # was a bad move to start with, so we'll hack in compatibility
      # until we get it fixed proper.
      token = params[:token].gsub(/^\$2y\$/, "$2a$").split("|")
      if token.size == 2
        token_user = User.find_by(hashed_password: token[0], email: token[1])

        unless token_user
          # If we couldn't find a user by Crystal BCrypt hash, try
          # again with PHP version, we have some migrated users with
          # the old PHP version.
          token_user = User.find_by(hashed_password: token[0].gsub(/^\$2a\$/, "$2y$"), email: token[1])
        end
      end

      unless token_user
        halt!(403, "Forbidden")

        # Contrary to the documented behaviour, halt! doesn't actually
        # break out early. Obviously a bug.
        return
      end
    end

    # Temporary email/password authentication.
    if params[:password]? && params[:email]?
      token_user = User.find_by!(email: params[:email])
      unless token_user.authenticate(params[:password])
        halt!(403, "Forbidden")

        return
      end
    end

    location = Time::Location.load("Europe/Copenhagen")
    date_from = Time.local(location).at_beginning_of_month
    date_to = Time.local(location).at_end_of_day.shift(days: -1)
    date_today = Time.local(location)

    if params[:month]?
      year = params[:year]? || Time.local(location).to_s("%Y")
      # Three letter month names.
      month_date = Time.parse("01-#{params[:month]}-#{year}", "%d-%b-%Y", location) rescue nil
      # Full month names (and everything in between).
      month_date ||= Time.parse("01-#{params[:month]}-#{year}", "%d-%B-%Y", location) rescue nil
      if month_date
        date_from = month_date

        if date_from.to_s("%Y%m") == date_today.to_s("%Y%m")
          # When it's the current month, use yesterday as to date.
          # We'll deal with the case of day == 1 later.
          date_to = date_today.shift(days: -1).at_end_of_day
        else
          date_to = month_date.at_end_of_month
        end
      end
    end

    # Go with last month to is less than from (happens when it's the
    # current month and it's the first of the month) or if there's not
    # enough workdays in the current one.
    if date_from > date_to
      date_from.to_s("%Y%m") == date_today.to_s("%Y%m") &&
        calc_work_days(date_from, date_today.at_beginning_of_day) < 1
      date_from = date_from.shift(months: -1)
      date_to = date_from.at_end_of_month
    end

    if params[:from]?
      date_from = Time.parse(params[:from], "%Y%m%d", location) rescue date_from
    end

    if params[:to]?
      date_to = Time.parse(params[:to], "%Y%m%d", location).at_end_of_day rescue date_to
    end

    user_entries = Hash(Int64, Array(Entry)).new do |hash, key|
      hash[key] = [] of Entry
    end

    user_cache = {} of Int64 => User
    Entry.where("spent_at >= ?", date_from.to_s("%F"))
      .where("spent_at <= ?", date_to.to_s("%F")).each do |entry|
      user_cache[entry.user_id!] ||= User.find! entry.user_id!
      # Only show non-contractors.
      user_entries[entry.user_id!] << entry unless user_cache[entry.user_id!].is_contractor
    end

    work_days = calc_work_days(date_from, date_to)

    users = [] of Responses::UserTimeSummary
    user_entries.each do |user_id, entries|
      users << Responses::UserTimeSummary.new(
        user_cache[user_id],
        entries,
        work_days,
        7.5, # Hardcoded for the moment being.
        !!(token_user && (token_user.is_admin || token_user.id! == user_id)),
        !!(token_user && token_user.is_admin),
      )
    end

    first = Entry.first!("ORDER BY spent_at")
    first_date = Time.parse(first.spent_at, "%Y-%m-%d", location)

    respond_with do
      json {
        {
          "success" => user_entries.present?,
          "users" => users,
          "date_start" => date_from.to_s("%Y%m%d"),
          "date_end" => date_to.to_s("%Y%m%d"),
          "hours_in_range" => ((users.map &.hours_goal).sum(0)).round(2),
          "hours_total_registered" => ((users.map &.hours).sum(0)).round(2),
          "rounded_hours_total_registered" => ((users.map &.rounded_hours).sum(0)).round(2),
          "misc" => {
            "working_days_in_range" => work_days,
            "first_entry" => {
              "year" => first_date.to_s("%Y"),
              "day" => first_date.to_s("%d"),
              "month" => first_date.to_s("%m"),
            },
          }
        }.to_json
      }
    end
  end

  def calc_work_days(from : Time, to : Time)
    work_days = 0

    loop do
      if from.day_of_week.monday? ||
         from.day_of_week.tuesday? ||
         from.day_of_week.wednesday? ||
         from.day_of_week.thursday? ||
         from.day_of_week.friday?
        work_days += 1
      end

      from = from.shift(days: 1)
      break if from > to
    end

    work_days
  end
end
