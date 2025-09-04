-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE entries ADD COLUMN billable BOOL NOT NULL DEFAULT false;
-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE entries DROP COLUMN billable;
