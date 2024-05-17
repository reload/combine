-- +micrate Up
CREATE TABLE entries (
  id INTEGER NOT NULL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  project_id BIGINT NOT NULL,
  task_id BIGINT NOT NULL,
  notes TEXT NOT NULL,
  hours REAL NOT NULL,
  is_closed BOOL NOT NULL,
  is_billed BOOL NOT NULL,
  spent_at DATE NOT NULL,
  timer_started_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
CREATE INDEX entry_user_id_idx ON entries (user_id);
CREATE INDEX entry_project_id_idx ON entries (project_id);
CREATE INDEX entry_task_id_idx ON entries (task_id);

-- +micrate Down
DROP TABLE IF EXISTS entries;
