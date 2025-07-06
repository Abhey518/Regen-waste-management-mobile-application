-- Create feedback table in Supabase
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    feedback_type VARCHAR(50) NOT NULL CHECK (feedback_type IN ('feedback', 'suggestion', 'bug_report')),
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved', 'closed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    admin_response TEXT,
    admin_id UUID REFERENCES auth.users(id),
    resolved_at TIMESTAMPTZ
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback(feedback_type);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_feedback_updated_at 
    BEFORE UPDATE ON feedback 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Set Row Level Security (RLS)
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own feedback
CREATE POLICY "Users can insert their own feedback" ON feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Policy: Users can view their own feedback
CREATE POLICY "Users can view their own feedback" ON feedback
    FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

-- Policy: Admins can view all feedback (you'll need to create an admin role)
-- CREATE POLICY "Admins can view all feedback" ON feedback
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM auth.users 
--             WHERE auth.users.id = auth.uid() 
--             AND auth.users.raw_app_meta_data->>'role' = 'admin'
--         )
--     );

-- Policy: Admins can update feedback status and add responses
-- CREATE POLICY "Admins can update feedback" ON feedback
--     FOR UPDATE USING (
--         EXISTS (
--             SELECT 1 FROM auth.users 
--             WHERE auth.users.id = auth.uid() 
--             AND auth.users.raw_app_meta_data->>'role' = 'admin'
--         )
--     );

-- Grant necessary permissions
GRANT SELECT, INSERT ON feedback TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Optional: Create a view for feedback statistics (for admin dashboard)
CREATE OR REPLACE VIEW feedback_stats AS
SELECT 
    feedback_type,
    status,
    COUNT(*) as count,
    DATE_TRUNC('day', created_at) as date
FROM feedback
GROUP BY feedback_type, status, DATE_TRUNC('day', created_at)
ORDER BY date DESC;

-- Grant access to the view
GRANT SELECT ON feedback_stats TO authenticated;
