class Task < Granite::Base
  connection sqlite
  table tasks

  column id : Int64, primary: true, auto: false
  column name : String
  column billable_by_default : Bool
  column created_at : Time
  column updated_at : Time

  # Override Granites created_at/updated_at handling.
  def set_timestamps(*, to time = Time.local(Granite.settings.default_timezone), mode = :create) end
end
