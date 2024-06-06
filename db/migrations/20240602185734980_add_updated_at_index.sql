-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE INDEX IF NOT EXISTS entries_updated_at_idx ON entries (updated_at);
CREATE INDEX IF NOT EXISTS users_updated_at_idx ON users (updated_at);
CREATE INDEX IF NOT EXISTS tasks_updated_at_idx ON tasks (updated_at);
CREATE INDEX IF NOT EXISTS projects_updated_at_idx ON projects (updated_at);
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP INDEX IF EXISTS entries_updated_at_idx;
DROP INDEX IF EXISTS users_updated_at_idx;
DROP INDEX IF EXISTS tasks_updated_at_idx;
DROP INDEX IF EXISTS projects_updated_at_idx;
