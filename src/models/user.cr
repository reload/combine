require "crypto/bcrypt/password"

class User < Granite::Base
  include Crypto
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
  column hashed_password : String?
  column created_at : Time
  column updated_at : Time

  def self.last_updated_at
    query "SELECT MAX(updated_at) FROM #{quoted_table_name}" { |rs|
      rs.move_next
      rs.read(Time?)}
  end

  def password=(password)
    @new_password = password
    @hashed_password = Bcrypt::Password.create(password, cost: 10).to_s
  end

  def password
    (hash = hashed_password) ? Bcrypt::Password.new(hash) : nil
  end

  def password_changed?
    new_password ? true : false
  end

  def valid_password_size?
    (pass = new_password) ? pass.size >= 8 : false
  end

  def authenticate(password : String)
    (bcrypt_pass = self.password) ? bcrypt_pass.verify(password) : false
  end

  # Override Granites created_at/updated_at handling.
  def set_timestamps(*, to time = Time.local(Granite.settings.default_timezone), mode = :create) end
end
