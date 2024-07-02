class Sync
  Log = ::Log.for("sync")

  def initialize(@harvest : Harvest::Service) end

  def run(all : Bool = false)
    tasks = @harvest.tasks(updated_since: Task.last_updated_at)
    tasks.each do |harvest_task|
      begin
        sync_task harvest_task
      rescue ex
        Log.error { "Error syncing task #{harvest_task.inspect}"}
      end
    end
    Log.info { "Processed #{tasks.size} tasks"}

    projects = @harvest.projects(updated_since: Project.last_updated_at)
    projects.each do |harvest_project|
      begin
        sync_project harvest_project
      rescue ex
        Log.error { "Error syncing project #{harvest_project.inspect}"}
      end
    end
    Log.info { "Processed #{projects.size} projects"}

    users = @harvest.users(updated_since: User.last_updated_at)
    users.each do |harvest_user|
      begin
        sync_user harvest_user
      rescue ex
        Log.error { "Error syncing user #{harvest_user.inspect}"}
      end
    end
    Log.info { "Processed #{users.size} users"}

    time_entries = @harvest.time_entries(updated_since: all ? nil : Entry.last_updated_at)
    time_entries.each do |harvest_entry|
      begin
        entry = sync_entry harvest_entry, all
      rescue ex
        Log.error { "Error syncing entry #{harvest_entry.inspect}"}
      end
    end
    Log.info { "Processed #{time_entries.size} time entries"}
  end

  # Clean out time entries deleted in Harvets
  def cleanup(from : Time, to : Time)
    existing_entries = Set(Int64).new

    time_entries = @harvest.time_entries(from: from, to: to).each do |harvest_entry|
      existing_entries.add(harvest_entry.id)
    end

    Entry.spent_between(from, to).each do |entry|
      entry.destroy unless existing_entries.includes? entry.id!
    end
  end

  def sync_user(harvest_user = Harvest::User) : User
    user = User.find harvest_user.id

    if !user || user.updated_at != harvest_user.updated_at
      data = {
        id: harvest_user.id,
        first_name: harvest_user.first_name,
        last_name: harvest_user.last_name,
        email: harvest_user.email,
        is_contractor: harvest_user.is_contractor ? 1 : 0,
        is_active: harvest_user.is_active ? 1 : 0,
        is_admin: harvest_user.access_roles.includes?("administrator") ? 1 : 0,
        created_at: harvest_user.created_at,
        updated_at: harvest_user.updated_at,
      }

      if !user
        user = User.create!(data)
        Log.info { "Created #{user.first_name} #{user.last_name}" }
      elsif user.updated_at != harvest_user.updated_at
        user.update!(data)
        Log.info { "Updated #{user.first_name} #{user.last_name}" }
      end
    end

    user
  end

  def sync_entry(harvest_entry : Harvest::TimeEntry, force : Bool = false) : Entry
    entry = Entry.find harvest_entry.id

    if !entry || force || entry.updated_at != harvest_entry.updated_at
      data = {
        id: harvest_entry.id,
        user_id: harvest_entry.user.id,
        project_id: harvest_entry.project.id,
        task_id: harvest_entry.task.id,
        notes: harvest_entry.notes,
        hours: harvest_entry.hours,
        rounded_hours: harvest_entry.rounded_hours,
        is_closed: harvest_entry.is_closed,
        is_billed: harvest_entry.is_billed,
        spent_at: harvest_entry.spent_date.to_s("%F"),
        timer_started_at: harvest_entry.timer_started_at,
        created_at: harvest_entry.created_at,
        updated_at: harvest_entry.updated_at,
      }

      if !entry
        entry = Entry.create!(data)
      else
        entry.update!(data)
      end
    end

    entry
  end

  def sync_task(harvest_task : Harvest::Task) : Task
    task = Task.find harvest_task.id

    if !task || task.updated_at != harvest_task.updated_at
      data = {
        id: harvest_task.id,
        name: harvest_task.name,
        billable_by_default: harvest_task.billable_by_default,
        created_at: harvest_task.created_at,
        updated_at: harvest_task.updated_at,
      }

      if !task
        task = Task.create!(data)
        Log.info { "Created #{task.name}" }
      elsif task.updated_at != harvest_task.updated_at
        task.update!(data)
        Log.info { "Updated #{task.name}" }
      end
    end

    task
  end

  def sync_project(harvest_project : Harvest::Project) : Project
    project = Project.find harvest_project.id

    if !project || project.updated_at != harvest_project.updated_at
      data = {
        id: harvest_project.id,
        name: harvest_project.name,
        is_active: harvest_project.is_active,
        is_billable: harvest_project.is_billable,
        created_at: harvest_project.created_at,
        updated_at: harvest_project.updated_at,
      }

      if !project
        project = Project.create!(data)
        Log.info { "Created #{project.name}" }
      elsif project.updated_at != harvest_project.updated_at
        project.update!(data)
        Log.info { "Updated #{project.name}" }
      end
    end

    project
  end
end
