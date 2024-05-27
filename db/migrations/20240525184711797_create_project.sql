-- +micrate Up
CREATE TABLE projects (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL,
  is_active BOOL NOT NULL,
  is_billable BOOL NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

-- +micrate Down
DROP TABLE IF EXISTS projects;
