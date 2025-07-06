-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general' CHECK (type IN ('general', 'pickup', 'urgent', 'announcement')),
    is_read BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    icon_name VARCHAR(100) DEFAULT 'notifications',
    action_url VARCHAR(500),
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- Enable Row Level Security (RLS)
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can see their own notifications AND global notifications (user_id IS NULL)
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

-- Users can mark their own notifications as read (including global ones)
CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

-- Only authenticated users with admin role can insert notifications
-- Note: You'll need to add a role field to your users table or use a separate admin table
-- Temporarily allowing all authenticated users to insert (remove this policy later)
CREATE POLICY "Authenticated users can insert notifications" ON notifications
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Admin can view all notifications (temporarily allowing all authenticated users)
CREATE POLICY "Authenticated users can view all notifications" ON notifications
    FOR SELECT USING (auth.uid() IS NOT NULL);

-- Admin can update all notifications (temporarily allowing all authenticated users)
CREATE POLICY "Authenticated users can update all notifications" ON notifications
    FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Admin can delete notifications (temporarily allowing all authenticated users)
CREATE POLICY "Authenticated users can delete notifications" ON notifications
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- Create function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- Insert some sample notifications (optional)
INSERT INTO notifications (title, message, type, user_id, icon_name, priority) VALUES
('Welcome to Regen!', 'Thank you for joining our waste management system. Get started by checking your pickup schedule.', 'announcement', NULL, 'celebration', 1),
('Pickup Reminder', 'Your next garbage pickup is scheduled for tomorrow at 10:00 AM. Please have your bins ready.', 'pickup', NULL, 'schedule', 2),
('System Maintenance', 'The app will undergo maintenance tonight from 12:00 AM to 2:00 AM. Some features may be unavailable.', 'urgent', NULL, 'build', 3);
