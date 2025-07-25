-- Location: supabase/migrations/20250725075100_medscanx_medical_system.sql
-- Schema Analysis: Fresh project - no existing tables found
-- Integration Type: Complete medical diagnostic system schema
-- Dependencies: None - creating base schema

-- 1. Custom Types
CREATE TYPE public.user_role AS ENUM ('patient', 'doctor', 'admin');
CREATE TYPE public.diagnostic_status AS ENUM ('pending', 'processing', 'completed', 'failed');
CREATE TYPE public.report_type AS ENUM ('xray', 'mri', 'lab_report', 'ct_scan', 'ultrasound');
CREATE TYPE public.severity_level AS ENUM ('normal', 'mild', 'moderate', 'severe', 'critical');
CREATE TYPE public.document_type AS ENUM ('medical_scan', 'lab_report', 'prescription', 'other');

-- 2. Core Tables
-- User profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'patient'::public.user_role,
    phone TEXT,
    date_of_birth DATE,
    gender TEXT,
    emergency_contact JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Medical reports main table
CREATE TABLE public.medical_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    report_type public.report_type NOT NULL,
    status public.diagnostic_status DEFAULT 'pending'::public.diagnostic_status,
    severity public.severity_level DEFAULT 'normal'::public.severity_level,
    original_file_url TEXT,
    processed_image_url TEXT,
    ai_analysis JSONB,
    doctor_notes TEXT,
    diagnosis TEXT,
    recommendations TEXT[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Document uploads table
CREATE TABLE public.document_uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    report_id UUID REFERENCES public.medical_reports(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_size BIGINT,
    file_type TEXT NOT NULL,
    document_type public.document_type DEFAULT 'medical_scan'::public.document_type,
    storage_path TEXT NOT NULL,
    upload_status TEXT DEFAULT 'completed',
    ocr_extracted_text TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- AI processing results table
CREATE TABLE public.ai_processing_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID REFERENCES public.medical_reports(id) ON DELETE CASCADE,
    processing_type TEXT NOT NULL,
    model_version TEXT,
    confidence_score DECIMAL(5,4),
    detected_conditions JSONB,
    gradcam_visualization_url TEXT,
    processing_time_seconds INTEGER,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Medical history tracking
CREATE TABLE public.medical_history_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    report_id UUID REFERENCES public.medical_reports(id) ON DELETE CASCADE,
    condition_name TEXT NOT NULL,
    diagnosed_date DATE,
    severity public.severity_level,
    treatment_notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Health metrics tracking
CREATE TABLE public.health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    metric_name TEXT NOT NULL,
    metric_value DECIMAL(10,2),
    metric_unit TEXT,
    recorded_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_medical_reports_patient_id ON public.medical_reports(patient_id);
CREATE INDEX idx_medical_reports_status ON public.medical_reports(status);
CREATE INDEX idx_medical_reports_report_type ON public.medical_reports(report_type);
CREATE INDEX idx_medical_reports_created_at ON public.medical_reports(created_at DESC);
CREATE INDEX idx_document_uploads_user_id ON public.document_uploads(user_id);
CREATE INDEX idx_document_uploads_report_id ON public.document_uploads(report_id);
CREATE INDEX idx_ai_processing_results_report_id ON public.ai_processing_results(report_id);
CREATE INDEX idx_medical_history_patient_id ON public.medical_history_entries(patient_id);
CREATE INDEX idx_health_metrics_patient_id ON public.health_metrics(patient_id);
CREATE INDEX idx_health_metrics_recorded_date ON public.health_metrics(recorded_date DESC);

-- 4. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_processing_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_history_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_metrics ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions
CREATE OR REPLACE FUNCTION public.is_own_profile(profile_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT profile_uuid = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.is_doctor()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'doctor'::public.user_role
)
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_medical_report(report_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.medical_reports mr
    WHERE mr.id = report_uuid 
    AND (mr.patient_id = auth.uid() OR mr.doctor_id = auth.uid() OR public.is_admin())
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_patient_data(patient_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT patient_uuid = auth.uid() OR public.is_doctor() OR public.is_admin()
$$;

-- Trigger function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'patient'::public.user_role)
  );  
  RETURN NEW;
END;
$$;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Triggers for updating timestamps
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_medical_reports_updated_at
    BEFORE UPDATE ON public.medical_reports
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 6. RLS Policies
-- User profiles policies
CREATE POLICY "users_can_view_own_profile"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (public.is_own_profile(id) OR public.is_doctor() OR public.is_admin());

CREATE POLICY "users_can_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (public.is_own_profile(id))
WITH CHECK (public.is_own_profile(id));

-- Medical reports policies
CREATE POLICY "authorized_medical_report_access"
ON public.medical_reports
FOR SELECT
TO authenticated
USING (public.can_access_medical_report(id));

CREATE POLICY "patients_create_own_reports"
ON public.medical_reports
FOR INSERT
TO authenticated
WITH CHECK (patient_id = auth.uid());

CREATE POLICY "authorized_medical_report_update"
ON public.medical_reports
FOR UPDATE
TO authenticated
USING (public.can_access_medical_report(id))
WITH CHECK (public.can_access_medical_report(id));

-- Document uploads policies
CREATE POLICY "users_manage_own_documents"
ON public.document_uploads
FOR ALL
TO authenticated
USING (user_id = auth.uid() OR public.is_doctor() OR public.is_admin())
WITH CHECK (user_id = auth.uid() OR public.is_doctor() OR public.is_admin());

-- AI processing results policies
CREATE POLICY "authorized_ai_results_access"
ON public.ai_processing_results
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.medical_reports mr
        WHERE mr.id = report_id AND public.can_access_medical_report(mr.id)
    )
);

-- Medical history policies
CREATE POLICY "authorized_medical_history_access"
ON public.medical_history_entries
FOR ALL
TO authenticated
USING (public.can_access_patient_data(patient_id))
WITH CHECK (public.can_access_patient_data(patient_id));

-- Health metrics policies
CREATE POLICY "authorized_health_metrics_access"
ON public.health_metrics
FOR ALL
TO authenticated
USING (public.can_access_patient_data(patient_id))
WITH CHECK (public.can_access_patient_data(patient_id));

-- 7. Complete Mock Data
DO $$
DECLARE
    patient1_uuid UUID := gen_random_uuid();
    patient2_uuid UUID := gen_random_uuid();
    doctor1_uuid UUID := gen_random_uuid();
    admin1_uuid UUID := gen_random_uuid();
    report1_uuid UUID := gen_random_uuid();
    report2_uuid UUID := gen_random_uuid();
    report3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (patient1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'patient@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Smith", "role": "patient"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (patient2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'jane.doe@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Jane Doe", "role": "patient"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (doctor1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'dr.johnson@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Sarah Johnson", "role": "doctor"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@medscanx.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "System Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert medical reports
    INSERT INTO public.medical_reports (id, patient_id, doctor_id, title, report_type, status, severity, diagnosis, recommendations) VALUES
        (report1_uuid, patient1_uuid, doctor1_uuid, 'Chest X-Ray Analysis', 'xray'::public.report_type, 'completed'::public.diagnostic_status, 'normal'::public.severity_level, 'No abnormalities detected in chest X-ray', ARRAY['Continue regular checkups', 'Maintain healthy lifestyle']),
        (report2_uuid, patient2_uuid, doctor1_uuid, 'Blood Test Report', 'lab_report'::public.report_type, 'completed'::public.diagnostic_status, 'mild'::public.severity_level, 'Slightly elevated cholesterol levels', ARRAY['Reduce saturated fat intake', 'Increase physical activity', 'Retest in 3 months']),
        (report3_uuid, patient1_uuid, doctor1_uuid, 'MRI Brain Scan', 'mri'::public.report_type, 'processing'::public.diagnostic_status, 'normal'::public.severity_level, 'Awaiting detailed analysis', ARRAY['Results pending']);

    -- Insert document uploads
    INSERT INTO public.document_uploads (user_id, report_id, file_name, file_size, file_type, document_type, storage_path, ocr_extracted_text) VALUES
        (patient1_uuid, report1_uuid, 'chest-xray-2025-01-15.jpg', 2048576, 'image/jpeg', 'medical_scan'::public.document_type, 'uploads/chest-xray-2025-01-15.jpg', 'Medical imaging data extracted'),
        (patient2_uuid, report2_uuid, 'blood-test-results.pdf', 1024768, 'application/pdf', 'lab_report'::public.document_type, 'uploads/blood-test-results.pdf', 'Cholesterol: 245 mg/dL, HDL: 45 mg/dL, LDL: 165 mg/dL'),
        (patient1_uuid, report3_uuid, 'mri-brain-scan.dcm', 52428800, 'application/dicom', 'medical_scan'::public.document_type, 'uploads/mri-brain-scan.dcm', 'DICOM medical imaging data');

    -- Insert AI processing results
    INSERT INTO public.ai_processing_results (report_id, processing_type, model_version, confidence_score, detected_conditions, processing_time_seconds) VALUES
        (report1_uuid, 'chest_xray_classification', 'ViT-B/16-v2.1', 0.9532, '{"conditions": [], "normal_probability": 0.9532}'::jsonb, 15),
        (report2_uuid, 'lab_report_analysis', 'BioBERT-v1.1', 0.8967, '{"conditions": [{"name": "High Cholesterol", "confidence": 0.8967}]}'::jsonb, 8);

    -- Insert medical history entries
    INSERT INTO public.medical_history_entries (patient_id, report_id, condition_name, diagnosed_date, severity, treatment_notes) VALUES
        (patient1_uuid, report1_uuid, 'Routine Chest X-Ray', '2025-01-15', 'normal'::public.severity_level, 'Annual preventive screening - no issues found'),
        (patient2_uuid, report2_uuid, 'Hypercholesterolemia', '2025-01-20', 'mild'::public.severity_level, 'Dietary modifications recommended, follow-up in 3 months');

    -- Insert health metrics
    INSERT INTO public.health_metrics (patient_id, metric_name, metric_value, metric_unit, recorded_date) VALUES
        (patient1_uuid, 'Blood Pressure Systolic', 120, 'mmHg', '2025-01-15'),
        (patient1_uuid, 'Blood Pressure Diastolic', 80, 'mmHg', '2025-01-15'),
        (patient1_uuid, 'Heart Rate', 72, 'bpm', '2025-01-15'),
        (patient2_uuid, 'Total Cholesterol', 245, 'mg/dL', '2025-01-20'),
        (patient2_uuid, 'HDL Cholesterol', 45, 'mg/dL', '2025-01-20'),
        (patient2_uuid, 'LDL Cholesterol', 165, 'mg/dL', '2025-01-20');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 8. Cleanup function for testing
CREATE OR REPLACE FUNCTION public.cleanup_test_medical_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@example.com' OR email LIKE '%@medscanx.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.health_metrics WHERE patient_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.medical_history_entries WHERE patient_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.ai_processing_results WHERE report_id IN (SELECT id FROM public.medical_reports WHERE patient_id = ANY(auth_user_ids_to_delete));
    DELETE FROM public.document_uploads WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.medical_reports WHERE patient_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;