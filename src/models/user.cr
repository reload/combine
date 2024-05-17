class User < Granite::Base
  connection sqlite
  table users

  column id : Int64, primary: true, auto: false
  column first_name : String
  column last_name : String
  column email : String
  column is_active : Bool
  column is_admin : Bool
  column is_contractor : Bool
  column working_hours : Float64 = 0
  column billability_goal : Float64 = 0 
  column password : String?
  column created_at : Time
  column updated_at : Time

  # Override Granites created_at/updated_at handling.
  def set_timestamps(*, to time = Time.local(Granite.settings.default_timezone), mode = :create) end
end
