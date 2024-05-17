-- +micrate Up
CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  is_active BOOL NOT NULL,
  is_admin BOOL NOT NULL,
  is_contractor BOOL NOT NULL,
  working_hours REAL DEFAULT 0,
  billability_goal REAL,
  password VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);


-- +micrate Down
DROP TABLE IF EXISTS users;
