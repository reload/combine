module Responses
  class UserTimeSummary
    include JSON::Serializable

    getter id : Int64
    getter first_name : String
    getter last_name : String
    getter full_name : String
    getter email : String
    # Hours registered.
    @[JSON::Field(ignore: true)]
    getter hours : Float64 = 0
    # Work hour goal for user.
    getter hours_goal : Float64
    # Hours registered, rounded.
    getter hours_registered : Float64 = 0
    @[JSON::Field(converter: Responses::OptionalConverter)]
    getter extra = Extra.new
    @[JSON::Field(converter: Responses::OptionalConverter)]
    getter admin = Admin.new

    @[JSON::Field(ignore: true)]
    getter working_hours_per_day = 0_f64

    # Cache of tasks.
    #
    # Granite doesn't cache relations, so we use a cache.
    @@tasks = {} of Int64 => Task
    @@projects = {} of Int64 => Project

    def initialize(
         user : User,
         entries : Array(Entry),
         work_days : Int32,
         default_work_hours_per_day : Float64,
         show_extra = false,
         is_admin = false,
       )
      @id = user.id.not_nil!
      @first_name = user.first_name
      @last_name = user.last_name
      @full_name = "#{@first_name} #{@last_name}"
      @email = user.email
      @working_hours_per_day = user.working_hours > 0 ? user.working_hours : default_work_hours_per_day
      @hours_goal = @working_hours_per_day * work_days

      @extra.emit = show_extra
      @admin.emit = is_admin

      entries.each do |entry|
        process_entry(entry)
      end

      @extra.working_days = work_days

      # Get actual working hours.
      @extra.working_hours = @hours - @extra.vacation - @extra.holiday -
                             @extra.time_off.normal - @extra.time_off.paternity_leave -
                             @extra.education

      if @extra.billable_hours.positive? && @extra.working_hours.positive?
        @extra.billability.of_working_hours = @extra.billable_hours / @extra.working_hours * 100

        @extra.billability.of_total_hours = @extra.billable_hours / @hours * 100

        @extra.billability.hours_pr_day = @extra.billable_hours / work_days

        # Admin stuff.
        @admin.billability.goal =
          user.billability_goal.positive? ? user.billability_goal : 75_f64
        @admin.billability.billable_hours_to_reach =
          (@admin.billability.goal / 100) * @extra.working_hours
        @admin.billability.performance =
          (@extra.billable_hours / @admin.billability.billable_hours_to_reach) * 100
      end

      # Normalized hours per day.
      non_work_hours = @hours - @extra.working_hours
      non_work_days = non_work_hours / @working_hours_per_day
      actual_work_days = work_days - non_work_days

      if actual_work_days.positive?
        # Actual amount of billable hours per day.
        @extra.billability.hours_pr_day_normalized = @extra.billable_hours / actual_work_days
      end

      round
    end

    # Round off numbers for display.
    #
    # to_json shows the numbers with maximum precision, which includes
    # floating point rounding errors. The old PHP version used two
    # decimals, as it rounds per default. So stick to the legacy
    # behaviour.
    def round
      @hours_registered = @hours.round(2)
      @extra.round
      @admin.round
    end

    def process_entry(entry : Entry)
      @@tasks[entry.task_id!] ||= entry.task
      task = @@tasks[entry.task_id!]
      @@projects[entry.project_id!] ||= entry.project
      project = @@projects[entry.project_id!]

      # Off hours doesn't count towards working hours.
      if task.name == "Off Hours - Driftsupport (ReOps)"
        @extra.off_hours += entry.hours
      else
        @hours += entry.hours
      end

      case task.name
      when "Helligdag"
        @extra.holiday += entry.hours
      when "Ferie"
        @extra.vacation += entry.hours
      when "Holder fri"
        @extra.time_off.normal += entry.hours
      when "Barsel"
        @extra.time_off.paternity_leave += entry.hours
      when "Sygdom"
        @extra.illness.normal += entry.hours
      when "Barns første sygedag"
        @extra.illness.child += entry.hours
      when "Uddannelse/Kursus"
        @extra.education += entry.hours
      end

      if task.billable_by_default && project.is_billable &&
         task.name != "Off Hours - Driftsupport (ReOps)"
        @extra.billable_hours += entry.hours
      end
    end
  end

  # Module for optional sub objects.
  module Optional
    include JSON::Serializable

    @[JSON::Field(ignore: true)]
    property? emit = false
  end

  # JSON converter that only emits objects that returns true from `#emit?`.
  module OptionalConverter
    def self.to_json(value : Optional, json : JSON::Builder) : Nil
      json.raw(value.emit? ? value.to_json : ([] of String).to_json)
    end
  end

  class Extra
    include JSON::Serializable
    include Optional

    property billable_hours = 0_f64
    property billability = Billability.new
    property holiday = 0_f64
    property time_off = TimeOff.new
    property education = 0_f64
    property vacation = 0_f64
    property illness = Illness.new
    property working_hours = 0_f64
    property working_days = 0_f64
    property off_hours = 0_f64

    def initialize() end

    def round
      @billable_hours = @billable_hours.round(2)
      @billability.round
      @holiday = @holiday.round(2)
      @time_off.round
      @education = @education.round(2)
      @vacation = @vacation.round(2)
      @illness.round
      @working_hours = @working_hours.round(2)
      @working_days = @working_days.round(2)
      @off_hours = @off_hours.round(2)
    end
  end

  class Billability
    include JSON::Serializable

    property of_total_hours = 0_f64
    property of_working_hours = 0_f64
    property hours_pr_day = 0_f64
    property hours_pr_day_normalized = 0_f64

    def initialize() end

    def round
      @of_total_hours = @of_total_hours.round(2)
      @of_working_hours = @of_working_hours.round(2)
      @hours_pr_day = @hours_pr_day.round(2)
      @hours_pr_day_normalized = @hours_pr_day_normalized.round(2)
    end
  end

  class TimeOff
    include JSON::Serializable

    property normal = 0_f64
    property paternity_leave = 0_f64

    def initialize() end

    def round
      @normal = @normal.round(2)
      @paternity_leave = @paternity_leave.round(2)
    end
  end

  class Illness
    include JSON::Serializable

    property normal = 0_f64
    property child = 0_f64

    def initialize() end

    def round
      @normal = @normal.round(2)
      @child = @child.round(2)
    end
  end

  class Admin
    include JSON::Serializable
    include Optional

    property billability = AdminBillability.new

    def initialize() end

    def round
      @billability.round
    end
  end

  class AdminBillability
    include JSON::Serializable

    property billable_hours_to_reach = 0_f64
    property goal = 0_f64
    property performance = 0_f64

    def initialize() end

    def round
      @billable_hours_to_reach = @billable_hours_to_reach.round(2)
      @goal = @goal.round(2)
      @performance = @performance.round(2)
    end
  end
end
