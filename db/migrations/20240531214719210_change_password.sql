-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE users RENAME COLUMN password TO hashed_password;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE users RENAME COLUMN hashed_password TO password;
