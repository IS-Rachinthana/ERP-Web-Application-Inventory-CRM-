-- Supabase Auth must not be blocked if a profile write fails. Profiles are created
-- securely by the authenticated dashboard on first successful sign-in instead.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
