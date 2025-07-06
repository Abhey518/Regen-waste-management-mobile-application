-- Add role column to users table (if it doesn't exist)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator'));

-- Create index for role column
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Update existing users to have 'user' role if role is null
UPDATE users SET role = 'user' WHERE role IS NULL;

-- Example: Set a specific user as admin (replace with actual user email/id)
-- UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';

-- Create a view for admin users
CREATE OR REPLACE VIEW admin_users AS
SELECT * FROM users WHERE role = 'admin';

-- Grant permissions for admin functions
-- These policies are already created in the notifications table creation script
