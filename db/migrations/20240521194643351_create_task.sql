-- +micrate Up
CREATE TABLE tasks (
  id INTEGER NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL,
  billable_by_default BOOL NOT NULL,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);


-- +micrate Down
DROP TABLE IF EXISTS tasks;
