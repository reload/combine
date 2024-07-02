-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE entries ADD COLUMN rounded_hours REAL NOT NULL DEFAULT 0;
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE entries DROP COLUMN rounded_hours;
