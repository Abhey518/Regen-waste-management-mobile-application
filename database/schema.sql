-- Database Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Shared Utility Functions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Table: provinces
CREATE TABLE provinces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Table: districts
CREATE TABLE districts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    province_id INTEGER NOT NULL REFERENCES provinces(id) ON DELETE CASCADE
);

-- Table: local_authorities
CREATE TABLE local_authorities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES districts(id) ON DELETE CASCADE
);

-- Table: users
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    nic_or_passport VARCHAR(50),
    address TEXT,
    province_id INTEGER REFERENCES provinces(id),
    district_id INTEGER REFERENCES districts(id),
    local_authority_id INTEGER REFERENCES local_authorities(id),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'moderator')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Table: garbage_pickup_schedule
CREATE TABLE garbage_pickup_schedule (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    province_id INTEGER REFERENCES provinces(id),
    district_id INTEGER REFERENCES districts(id),
    local_authority_id INTEGER REFERENCES local_authorities(id),
    pickup_date DATE NOT NULL,
    pickup_time_start TIME NOT NULL,
    pickup_time_end TIME NOT NULL,
    waste_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'scheduled',
    is_recurring BOOLEAN DEFAULT true,
    recurrence_type VARCHAR(20) DEFAULT 'weekly',
    created_by UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT valid_location_hierarchy CHECK (
        (province_id IS NOT NULL) AND 
        (district_id IS NOT NULL) AND 
        (local_authority_id IS NOT NULL)
    )
);

CREATE INDEX idx_garbage_schedule_location ON garbage_pickup_schedule(province_id, district_id, local_authority_id);
CREATE INDEX idx_garbage_schedule_date ON garbage_pickup_schedule(pickup_date);
CREATE INDEX idx_garbage_schedule_status ON garbage_pickup_schedule(status);

CREATE TRIGGER update_garbage_schedule_updated_at 
    BEFORE UPDATE ON garbage_pickup_schedule 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE garbage_pickup_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view pickup schedules for their location" ON garbage_pickup_schedule 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.province_id = garbage_pickup_schedule.province_id 
            AND users.district_id = garbage_pickup_schedule.district_id 
            AND users.local_authority_id = garbage_pickup_schedule.local_authority_id
        )
    );

CREATE POLICY "Only admins can insert pickup schedules" ON garbage_pickup_schedule 
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

CREATE POLICY "Only admins can update pickup schedules" ON garbage_pickup_schedule 
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

CREATE POLICY "Only admins can delete pickup schedules" ON garbage_pickup_schedule 
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

-- Table: area_schedule_templates
CREATE TABLE area_schedule_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    province_id INTEGER REFERENCES provinces(id),
    district_id INTEGER REFERENCES districts(id),
    local_authority_id INTEGER REFERENCES local_authorities(id),
    day_of_week INTEGER NOT NULL,
    pickup_time_start TIME NOT NULL,
    pickup_time_end TIME NOT NULL,
    waste_type VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT valid_template_location CHECK (
        (province_id IS NOT NULL) AND 
        (district_id IS NOT NULL) AND 
        (local_authority_id IS NOT NULL)
    ),
    UNIQUE(province_id, district_id, local_authority_id, day_of_week, waste_type)
);

CREATE INDEX idx_area_templates_location ON area_schedule_templates(province_id, district_id, local_authority_id, day_of_week);

CREATE TRIGGER update_area_templates_updated_at 
    BEFORE UPDATE ON area_schedule_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE area_schedule_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view area schedule templates" ON area_schedule_templates 
    FOR SELECT USING (true);

CREATE POLICY "Only admins can modify area schedule templates" ON area_schedule_templates 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() 
            AND role = 'admin'
        )
    );

-- Table: notifications
CREATE TABLE notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general' CHECK (type IN ('general', 'pickup', 'urgent', 'announcement')),
    is_read BOOLEAN DEFAULT FALSE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    icon_name VARCHAR(100) DEFAULT 'notifications',
    action_url VARCHAR(500),
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5)
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Authenticated users can insert notifications" ON notifications
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can view all notifications" ON notifications
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update all notifications" ON notifications
    FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can delete notifications" ON notifications
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- Table: feedback
CREATE TABLE feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255),
    feedback_type VARCHAR(50) NOT NULL CHECK (feedback_type IN ('feedback', 'suggestion', 'bug_report')),
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_review', 'resolved', 'closed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    admin_response TEXT,
    admin_id UUID REFERENCES users(id),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback(feedback_type);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at);

CREATE TRIGGER update_feedback_updated_at 
    BEFORE UPDATE ON feedback 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own feedback" ON feedback
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can view their own feedback" ON feedback
    FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

GRANT SELECT, INSERT ON feedback TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Table: dumping_reports
CREATE TABLE dumping_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    location TEXT NOT NULL,
    location_data JSONB,
    image_url TEXT NOT NULL,
    analysis_result JSONB,
    total_objects INTEGER,
    reported_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved'))
);

CREATE INDEX IF NOT EXISTS idx_dumping_reports_user ON dumping_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_dumping_reports_status ON dumping_reports(status);

-- Table: kids_posts
CREATE TABLE kids_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    image_url TEXT NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    quiz_question TEXT NOT NULL,
    quiz_options TEXT[] NOT NULL,
    correct_answer_index INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: kids_quiz_completions
CREATE TABLE kids_quiz_completions (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES kids_posts(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, post_id)
);

-- Table: articles
CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    image_url TEXT NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- View: admin_users
CREATE OR REPLACE VIEW admin_users AS
SELECT * FROM users WHERE role = 'admin';

-- View: feedback_stats
CREATE OR REPLACE VIEW feedback_stats AS
SELECT 
    feedback_type,
    status,
    COUNT(*) as count,
    DATE_TRUNC('day', created_at) as date
FROM feedback
GROUP BY feedback_type, status, DATE_TRUNC('day', created_at)
ORDER BY date DESC;

GRANT SELECT ON feedback_stats TO authenticated;

-- View: pickup_schedules_with_locations
CREATE OR REPLACE VIEW pickup_schedules_with_locations AS
SELECT 
    gps.*,
    p.name as province_name,
    d.name as district_name, 
    la.name as local_authority_name,
    CONCAT(p.name, ' > ', d.name, ' > ', la.name) as full_location_path,
    u.first_name || ' ' || u.last_name as created_by_name
FROM garbage_pickup_schedule gps
LEFT JOIN provinces p ON gps.province_id = p.id
LEFT JOIN districts d ON gps.district_id = d.id  
LEFT JOIN local_authorities la ON gps.local_authority_id = la.id
LEFT JOIN users u ON gps.created_by = u.id;

-- View: schedule_templates_with_locations
CREATE OR REPLACE VIEW schedule_templates_with_locations AS
SELECT 
    ast.*,
    p.name as province_name,
    d.name as district_name,
    la.name as local_authority_name,
    CONCAT(p.name, ' > ', d.name, ' > ', la.name) as full_location_path,
    CASE ast.day_of_week
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday' 
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
        WHEN 7 THEN 'Sunday'
    END as day_name
FROM area_schedule_templates ast
LEFT JOIN provinces p ON ast.province_id = p.id
LEFT JOIN districts d ON ast.district_id = d.id
LEFT JOIN local_authorities la ON ast.local_authority_id = la.id;

-- Helper Function to automatically generate schedules from templates
CREATE OR REPLACE FUNCTION generate_schedules_from_templates()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    template_record RECORD;
    target_date DATE;
    days_ahead INTEGER;
BEGIN
    FOR days_ahead IN 0..30 LOOP
        target_date := CURRENT_DATE + days_ahead;
        
        FOR template_record IN 
            SELECT * FROM area_schedule_templates 
            WHERE day_of_week = EXTRACT(dow FROM target_date)::INTEGER
            AND is_active = true
        Loop
            INSERT INTO garbage_pickup_schedule (
                province_id,
                district_id,
                local_authority_id,
                pickup_date, 
                pickup_time_start, 
                pickup_time_end, 
                waste_type,
                status,
                created_by
            )
            SELECT 
                template_record.province_id,
                template_record.district_id,
                template_record.local_authority_id,
                target_date,
                template_record.pickup_time_start,
                template_record.pickup_time_end,
                template_record.waste_type,
                'scheduled',
                NULL
            WHERE NOT EXISTS (
                SELECT 1 FROM garbage_pickup_schedule 
                WHERE province_id = template_record.province_id
                AND district_id = template_record.district_id
                AND local_authority_id = template_record.local_authority_id
                AND pickup_date = target_date 
                AND waste_type = template_record.waste_type
            );
        END LOOP;
    END LOOP;
END;
$$;
