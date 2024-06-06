class Entry < Granite::Base
  connection sqlite
  table entries

  belongs_to :user

  belongs_to :project

  belongs_to :task

  column id : Int64, primary: true, auto: false
  column notes : String
  column hours : Float64
  column is_closed : Bool
  column is_billed : Bool
  column spent_at : String
  column timer_started_at : Time?
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
