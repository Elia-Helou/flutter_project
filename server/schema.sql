-- Add reset_code column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(6); 