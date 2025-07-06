-- Create garbage_pickup_schedule table
CREATE TABLE IF NOT EXISTS garbage_pickup_schedule (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    province_id INTEGER REFERENCES provinces(id),
    district_id INTEGER REFERENCES districts(id),
    local_authority_id INTEGER REFERENCES local_authorities(id),
    pickup_date DATE NOT NULL,
    pickup_time_start TIME NOT NULL,
    pickup_time_end TIME NOT NULL,
    waste_type VARCHAR(50) NOT NULL, -- 'Plastic/Polythene', 'Organic Waste'
    status VARCHAR(20) DEFAULT 'scheduled', -- 'scheduled', 'in_progress', 'completed', 'cancelled'
    is_recurring BOOLEAN DEFAULT true,
    recurrence_type VARCHAR(20) DEFAULT 'weekly', -- 'weekly', 'monthly', 'custom'
    created_by UUID REFERENCES users(id), -- Admin who created this schedule
    notes TEXT, -- Additional notes for the pickup
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT valid_location_hierarchy CHECK (
        (province_id IS NOT NULL) AND 
        (district_id IS NOT NULL) AND 
        (local_authority_id IS NOT NULL)
    )
);

-- Create area_schedule_templates table for location-based recurring schedules
CREATE TABLE IF NOT EXISTS area_schedule_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    province_id INTEGER REFERENCES provinces(id),
    district_id INTEGER REFERENCES districts(id),
    local_authority_id INTEGER REFERENCES local_authorities(id),
    day_of_week INTEGER NOT NULL, -- 1=Monday, 2=Tuesday, ..., 7=Sunday
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

-- Create user_areas table to associate users with their areas (REMOVED - using user location directly)
-- Users location comes from users table: province_id, district_id, local_authority_id

-- Enable Row Level Security
ALTER TABLE garbage_pickup_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE area_schedule_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies for garbage_pickup_schedule (Users can only view schedules for their location)
CREATE POLICY "Users can view pickup schedules for their location" ON garbage_pickup_schedule FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.province_id = garbage_pickup_schedule.province_id 
        AND users.district_id = garbage_pickup_schedule.district_id 
        AND users.local_authority_id = garbage_pickup_schedule.local_authority_id
    )
);

CREATE POLICY "Only admins can insert pickup schedules" ON garbage_pickup_schedule FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND role = 'admin'
    )
);

CREATE POLICY "Only admins can update pickup schedules" ON garbage_pickup_schedule FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND role = 'admin'
    )
);

CREATE POLICY "Only admins can delete pickup schedules" ON garbage_pickup_schedule FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND role = 'admin'
    )
);

-- RLS Policies for area_schedule_templates (public read, admin write)
CREATE POLICY "Anyone can view area schedule templates" ON area_schedule_templates FOR SELECT USING (true);

CREATE POLICY "Only admins can modify area schedule templates" ON area_schedule_templates FOR ALL USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() 
        AND role = 'admin'
    )
);

-- Create indexes for better performance
CREATE INDEX idx_garbage_schedule_location ON garbage_pickup_schedule(province_id, district_id, local_authority_id);
CREATE INDEX idx_garbage_schedule_date ON garbage_pickup_schedule(pickup_date);
CREATE INDEX idx_garbage_schedule_status ON garbage_pickup_schedule(status);
CREATE INDEX idx_area_templates_location ON area_schedule_templates(province_id, district_id, local_authority_id, day_of_week);

-- Function to automatically generate schedules from templates
CREATE OR REPLACE FUNCTION generate_schedules_from_templates()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    template_record RECORD;
    target_date DATE;
    days_ahead INTEGER;
BEGIN
    -- Generate schedules for the next 30 days
    FOR days_ahead IN 0..30 LOOP
        target_date := CURRENT_DATE + days_ahead;
        
        -- For each active template that matches today's day of week
        FOR template_record IN 
            SELECT * FROM area_schedule_templates 
            WHERE day_of_week = EXTRACT(dow FROM target_date)::INTEGER
            AND is_active = true
        LOOP
            -- Insert schedule if it doesn't already exist
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
                NULL -- System generated, no specific admin
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

-- Insert sample area schedule templates
INSERT INTO area_schedule_templates (province_id, district_id, local_authority_id, day_of_week, pickup_time_start, pickup_time_end, waste_type) VALUES
-- Sample templates - Replace with actual province/district/local_authority IDs from your database
-- You can get the IDs by running: SELECT * FROM provinces; SELECT * FROM districts; SELECT * FROM local_authorities;

-- Example for Province 1, District 1, Local Authority 1 (Monday and Wednesday pickups)
(1, 1, 1, 1, '09:00', '11:00', 'Organic Waste'),
(1, 1, 1, 3, '13:00', '15:00', 'Plastic/Polythene'),

-- Example for Province 1, District 1, Local Authority 2 (Tuesday and Thursday pickups) 
(1, 1, 2, 2, '10:00', '12:00', 'Organic Waste'),
(1, 1, 2, 4, '14:00', '16:00', 'Plastic/Polythene'),

-- Example for Province 1, District 2, Local Authority 3 (Wednesday and Friday pickups)
(1, 2, 3, 3, '08:00', '10:00', 'Organic Waste'),
(1, 2, 3, 5, '13:00', '15:00', 'Plastic/Polythene');

-- Note: Replace these sample IDs with actual values from your location tables

-- Sample user setup (commented out - users register themselves with location)
-- Users already have location information in the users table
-- No need for separate user_areas table

-- Generate initial schedules from templates
SELECT generate_schedules_from_templates();

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to update updated_at
CREATE TRIGGER update_garbage_schedule_updated_at BEFORE UPDATE ON garbage_pickup_schedule 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_area_templates_updated_at BEFORE UPDATE ON area_schedule_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create a view for easier pickup schedule management with location names
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

-- Create a view for schedule templates with location names
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
