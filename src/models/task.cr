class Task < Granite::Base
  connection sqlite
  table tasks

  column id : Int64, primary: true, auto: false
  column name : String
  column billable_by_default : Bool
  column created_at : Time
  column updated_at : Time

  def self.last_updated_at
    query "SELECT MAX(updated_at) FROM #{quoted_table_name}" { |rs|
      rs.move_next
      rs.read(Time?)}
  end

  # Override Granites created_at/updated_at handling.
  def set_timestamps(*, to time = Time.local(Granite.settings.default_timezone), mode = :create) end
end
