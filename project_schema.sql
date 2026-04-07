--
-- PostgreSQL database dump
--

\restrict 0lHH4PlsWEl9rsTYqwBwMKffvR6LkMj0cBVfs4OjZuZpBf6BebDvtP8hGULFe5b

-- Dumped from database version 17.8 (a48d9ca)
-- Dumped by pg_dump version 17.9 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_profiles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.academic_profiles (
    id uuid NOT NULL,
    user_id uuid,
    overall_percentage_band text DEFAULT 'What was your percentage range in the last academic year?'::text,
    strongest_subject text DEFAULT 'In which subject do you score the highest?'::text,
    weakest_subject text DEFAULT 'Which subject do you find most challenging?'::text,
    favorite_subject text DEFAULT 'Which subject do you actually enjoy studying most?'::text,
    learning_style text DEFAULT 'Do you prefer Visual, Auditory, or Practical learning?'::text,
    study_hours_home text DEFAULT 'How many hours do you spend on self-study daily?'::text,
    homework_completion text DEFAULT 'How consistently do you complete your assignments?'::text,
    achievements text DEFAULT 'List any notable academic or co-curricular achievements.'::text,
    updated_at timestamp with time zone,
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.academic_profiles OWNER TO neondb_owner;

--
-- Name: aspiration_profiles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.aspiration_profiles (
    id uuid NOT NULL,
    user_id uuid,
    dream_career text DEFAULT 'If you could be anything, what would you be?'::text,
    life_direction text DEFAULT 'What is the primary goal of your life right now?'::text,
    ten_year_vision text DEFAULT 'Where do you see yourself in 2036?'::text,
    updated_at timestamp with time zone,
    why_this_career text,
    what_matters_most text,
    what_drives_you text,
    what_stops_you text,
    goal_clarity text,
    steps_taken text,
    no_constraints_vision text,
    five_year_goal text,
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.aspiration_profiles OWNER TO neondb_owner;

--
-- Name: career_skills; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.career_skills (
    career_id uuid NOT NULL,
    skill_id uuid NOT NULL,
    weight integer
);


ALTER TABLE public.career_skills OWNER TO neondb_owner;

--
-- Name: careers; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.careers (
    id uuid NOT NULL,
    title character varying NOT NULL,
    description text,
    base_success_probability double precision
);


ALTER TABLE public.careers OWNER TO neondb_owner;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.chat_messages (
    id uuid NOT NULL,
    sender_id uuid,
    message text NOT NULL,
    sent_at timestamp with time zone DEFAULT now(),
    student_id uuid,
    mentor_id uuid
);


ALTER TABLE public.chat_messages OWNER TO neondb_owner;

--
-- Name: financial_profiles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.financial_profiles (
    id uuid NOT NULL,
    user_id uuid,
    family_structure text DEFAULT 'Describe your family (e.g., Nuclear, Joint, Single Parent).'::text,
    income_band text DEFAULT 'What is your family''s annual income bracket?'::text,
    father_education text DEFAULT 'What is your father''s highest level of education?'::text,
    mother_education text DEFAULT 'What is your mother''s highest level of education?'::text,
    affordability_level text DEFAULT 'How much financial support is available for your higher education?'::text,
    coaching_access text DEFAULT 'Do you have access to private tuitions or entrance coaching?'::text,
    updated_at timestamp with time zone,
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.financial_profiles OWNER TO neondb_owner;

--
-- Name: lifestyle_profiles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.lifestyle_profiles (
    id uuid NOT NULL,
    screen_time text DEFAULT 'How much time do you spend on non-academic screen use?'::text,
    sleep_quality text DEFAULT 'How would you rate your sleep and energy levels?'::text,
    stress_level text,
    updated_at timestamp with time zone,
    study_hours text DEFAULT 'How many hours do you dedicate to deep work?'::text,
    routine_consistency text DEFAULT 'How strictly do you follow your daily schedule?'::text,
    distraction_level text DEFAULT 'How easily do you get distracted while studying?'::text,
    task_completion text,
    reaction_to_failure text DEFAULT 'How do you typically handle a setback or bad grade?'::text,
    pressure_handling text DEFAULT 'How do you perform under tight deadlines?'::text,
    social_preference text DEFAULT 'Do you prefer group study or solo focus?'::text,
    focus_ability text DEFAULT 'How long can you maintain a single-task flow state?'::text,
    biggest_distraction text DEFAULT 'What is the #1 thing that breaks your focus?'::text,
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.lifestyle_profiles OWNER TO neondb_owner;

--
-- Name: mentor_availability; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.mentor_availability (
    id uuid NOT NULL,
    mentor_id uuid,
    day_of_week integer,
    start_time time without time zone,
    end_time time without time zone,
    is_booked boolean
);


ALTER TABLE public.mentor_availability OWNER TO neondb_owner;

--
-- Name: mentor_feedback; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.mentor_feedback (
    id uuid NOT NULL,
    session_id uuid,
    mentor_id uuid,
    student_id uuid,
    notes text,
    action_items text,
    submitted_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mentor_feedback OWNER TO neondb_owner;

--
-- Name: mentors; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.mentors (
    id uuid NOT NULL,
    user_id uuid,
    expertise character varying,
    rating double precision,
    is_verified boolean DEFAULT true,
    bio character varying(255),
    years_experience integer DEFAULT 0,
    expertise_vector public.vector(384)
);


ALTER TABLE public.mentors OWNER TO neondb_owner;

--
-- Name: mentorship_requests; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.mentorship_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    mentor_id uuid NOT NULL,
    availability_id uuid,
    message text,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mentorship_requests OWNER TO neondb_owner;

--
-- Name: parent_feedback; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.parent_feedback (
    id uuid NOT NULL,
    parent_id uuid,
    student_id uuid,
    behavior_insights text,
    study_habits text,
    logged_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.parent_feedback OWNER TO neondb_owner;

--
-- Name: parent_student_links; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.parent_student_links (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid NOT NULL,
    student_id uuid NOT NULL,
    linked_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.parent_student_links OWNER TO neondb_owner;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    user_id uuid,
    full_name text DEFAULT 'Please enter your full name.'::text NOT NULL,
    dob text DEFAULT 'What is your date of birth?'::text,
    gender text DEFAULT 'What is your gender?'::text,
    current_class text DEFAULT 'Which class are you currently studying in?'::text,
    school_type text DEFAULT 'What type of school do you attend (e.g., Private, Government)?'::text,
    state text DEFAULT 'Which state do you reside in?'::text,
    area_type text,
    medium_of_learning text DEFAULT 'What is your primary medium of instruction?'::text,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.profiles OWNER TO neondb_owner;

--
-- Name: results; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.results (
    id uuid NOT NULL,
    user_id uuid,
    test_id uuid,
    overall_score double precision,
    speed_score double precision,
    accuracy_score double precision,
    consistency_score double precision,
    weakness_mapping jsonb,
    completed_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.results OWNER TO neondb_owner;

--
-- Name: roadmap_milestones; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roadmap_milestones (
    id uuid NOT NULL,
    roadmap_id uuid,
    skill_id uuid,
    month_number integer,
    title character varying NOT NULL,
    description text,
    status character varying,
    completed_at timestamp with time zone
);


ALTER TABLE public.roadmap_milestones OWNER TO neondb_owner;

--
-- Name: roadmap_phases; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roadmap_phases (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    roadmap_id uuid NOT NULL,
    sequence integer NOT NULL,
    title character varying(255) NOT NULL,
    status character varying(50) DEFAULT 'Not Started'::character varying,
    progress_percentage double precision DEFAULT 0.0
);


ALTER TABLE public.roadmap_phases OWNER TO neondb_owner;

--
-- Name: roadmap_tasks; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roadmap_tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    phase_id uuid NOT NULL,
    sequence integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    status character varying(50) DEFAULT 'Not Started'::character varying
);


ALTER TABLE public.roadmap_tasks OWNER TO neondb_owner;

--
-- Name: roadmaps; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roadmaps (
    id uuid NOT NULL,
    student_id uuid,
    career_id uuid,
    total_months integer,
    generated_at timestamp with time zone DEFAULT now(),
    title character varying NOT NULL,
    description text,
    status character varying DEFAULT 'Overview'::character varying,
    progress_percentage double precision DEFAULT 0.0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.roadmaps OWNER TO neondb_owner;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.sessions (
    id uuid NOT NULL,
    student_id uuid,
    mentor_id uuid,
    scheduled_at timestamp with time zone NOT NULL,
    duration_minutes integer NOT NULL,
    status character varying,
    meeting_url character varying,
    dyte_meeting_id character varying
);


ALTER TABLE public.sessions OWNER TO neondb_owner;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.skills (
    id uuid NOT NULL,
    name character varying NOT NULL,
    category character varying
);


ALTER TABLE public.skills OWNER TO neondb_owner;

--
-- Name: student_insights; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.student_insights (
    id uuid NOT NULL,
    student_id uuid,
    ai_summary text,
    recommended_career_id uuid,
    success_probability double precision,
    feasibility_score double precision,
    passion_skill_gap double precision,
    generated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.student_insights OWNER TO neondb_owner;

--
-- Name: tests; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.tests (
    id uuid NOT NULL,
    title character varying NOT NULL,
    type character varying NOT NULL,
    total_questions integer
);


ALTER TABLE public.tests OWNER TO neondb_owner;

--
-- Name: user_skills; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.user_skills (
    user_id uuid NOT NULL,
    skill_id uuid NOT NULL,
    score double precision,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.user_skills OWNER TO neondb_owner;

--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying NOT NULL,
    hashed_password character varying NOT NULL,
    role public.userrole NOT NULL,
    preferred_language character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    academic_data jsonb DEFAULT '{}'::jsonb,
    apti_data jsonb DEFAULT '{}'::jsonb,
    personality_data jsonb DEFAULT '{}'::jsonb,
    lifestyle_data jsonb DEFAULT '{}'::jsonb,
    financial_data jsonb DEFAULT '{}'::jsonb,
    psychometric_data jsonb DEFAULT '{}'::jsonb,
    aspiration_data jsonb DEFAULT '{}'::jsonb,
    career_interest_data jsonb,
    passion_strength_data jsonb,
    full_name character varying,
    invite_code character varying(6),
    profile_data jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: academic_profiles academic_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.academic_profiles
    ADD CONSTRAINT academic_profiles_pkey PRIMARY KEY (id);


--
-- Name: academic_profiles academic_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.academic_profiles
    ADD CONSTRAINT academic_profiles_user_id_key UNIQUE (user_id);


--
-- Name: aspiration_profiles aspiration_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.aspiration_profiles
    ADD CONSTRAINT aspiration_profiles_pkey PRIMARY KEY (id);


--
-- Name: aspiration_profiles aspiration_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.aspiration_profiles
    ADD CONSTRAINT aspiration_profiles_user_id_key UNIQUE (user_id);


--
-- Name: career_skills career_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_skills
    ADD CONSTRAINT career_skills_pkey PRIMARY KEY (career_id, skill_id);


--
-- Name: careers careers_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.careers
    ADD CONSTRAINT careers_pkey PRIMARY KEY (id);


--
-- Name: careers careers_title_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.careers
    ADD CONSTRAINT careers_title_key UNIQUE (title);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: financial_profiles financial_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.financial_profiles
    ADD CONSTRAINT financial_profiles_pkey PRIMARY KEY (id);


--
-- Name: financial_profiles financial_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.financial_profiles
    ADD CONSTRAINT financial_profiles_user_id_key UNIQUE (user_id);


--
-- Name: lifestyle_profiles lifestyle_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.lifestyle_profiles
    ADD CONSTRAINT lifestyle_profiles_pkey PRIMARY KEY (id);


--
-- Name: mentor_availability mentor_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_availability
    ADD CONSTRAINT mentor_availability_pkey PRIMARY KEY (id);


--
-- Name: mentor_feedback mentor_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_feedback
    ADD CONSTRAINT mentor_feedback_pkey PRIMARY KEY (id);


--
-- Name: mentors mentors_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentors
    ADD CONSTRAINT mentors_pkey PRIMARY KEY (id);


--
-- Name: mentors mentors_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentors
    ADD CONSTRAINT mentors_user_id_key UNIQUE (user_id);


--
-- Name: mentorship_requests mentorship_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentorship_requests
    ADD CONSTRAINT mentorship_requests_pkey PRIMARY KEY (id);


--
-- Name: parent_feedback parent_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_feedback
    ADD CONSTRAINT parent_feedback_pkey PRIMARY KEY (id);


--
-- Name: parent_student_links parent_student_links_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_student_links
    ADD CONSTRAINT parent_student_links_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: results results_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.results
    ADD CONSTRAINT results_pkey PRIMARY KEY (id);


--
-- Name: roadmap_milestones roadmap_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_milestones
    ADD CONSTRAINT roadmap_milestones_pkey PRIMARY KEY (id);


--
-- Name: roadmap_phases roadmap_phases_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_phases
    ADD CONSTRAINT roadmap_phases_pkey PRIMARY KEY (id);


--
-- Name: roadmap_tasks roadmap_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_tasks
    ADD CONSTRAINT roadmap_tasks_pkey PRIMARY KEY (id);


--
-- Name: roadmaps roadmaps_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmaps
    ADD CONSTRAINT roadmaps_pkey PRIMARY KEY (id);


--
-- Name: roadmaps roadmaps_student_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmaps
    ADD CONSTRAINT roadmaps_student_id_key UNIQUE (student_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: skills skills_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_name_key UNIQUE (name);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: student_insights student_insights_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.student_insights
    ADD CONSTRAINT student_insights_pkey PRIMARY KEY (id);


--
-- Name: student_insights student_insights_student_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.student_insights
    ADD CONSTRAINT student_insights_student_id_key UNIQUE (student_id);


--
-- Name: tests tests_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_pkey PRIMARY KEY (id);


--
-- Name: user_skills user_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_skills
    ADD CONSTRAINT user_skills_pkey PRIMARY KEY (user_id, skill_id);


--
-- Name: users users_invite_code_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_invite_code_key UNIQUE (invite_code);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: academic_profiles academic_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.academic_profiles
    ADD CONSTRAINT academic_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: aspiration_profiles aspiration_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.aspiration_profiles
    ADD CONSTRAINT aspiration_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: career_skills career_skills_career_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_skills
    ADD CONSTRAINT career_skills_career_id_fkey FOREIGN KEY (career_id) REFERENCES public.careers(id) ON DELETE CASCADE;


--
-- Name: career_skills career_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_skills
    ADD CONSTRAINT career_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.mentors(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: financial_profiles financial_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.financial_profiles
    ADD CONSTRAINT financial_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: roadmap_tasks fk_phase; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_tasks
    ADD CONSTRAINT fk_phase FOREIGN KEY (phase_id) REFERENCES public.roadmap_phases(id) ON DELETE CASCADE;


--
-- Name: roadmap_phases fk_roadmap; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_phases
    ADD CONSTRAINT fk_roadmap FOREIGN KEY (roadmap_id) REFERENCES public.roadmaps(id) ON DELETE CASCADE;


--
-- Name: mentor_availability mentor_availability_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_availability
    ADD CONSTRAINT mentor_availability_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.mentors(id) ON DELETE CASCADE;


--
-- Name: mentor_feedback mentor_feedback_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_feedback
    ADD CONSTRAINT mentor_feedback_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.mentors(id) ON DELETE CASCADE;


--
-- Name: mentor_feedback mentor_feedback_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_feedback
    ADD CONSTRAINT mentor_feedback_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: mentor_feedback mentor_feedback_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentor_feedback
    ADD CONSTRAINT mentor_feedback_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: mentors mentors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentors
    ADD CONSTRAINT mentors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: mentorship_requests mentorship_requests_availability_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentorship_requests
    ADD CONSTRAINT mentorship_requests_availability_id_fkey FOREIGN KEY (availability_id) REFERENCES public.mentor_availability(id) ON DELETE CASCADE;


--
-- Name: mentorship_requests mentorship_requests_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentorship_requests
    ADD CONSTRAINT mentorship_requests_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.mentors(id) ON DELETE CASCADE;


--
-- Name: mentorship_requests mentorship_requests_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.mentorship_requests
    ADD CONSTRAINT mentorship_requests_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: parent_feedback parent_feedback_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_feedback
    ADD CONSTRAINT parent_feedback_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: parent_feedback parent_feedback_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_feedback
    ADD CONSTRAINT parent_feedback_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: parent_student_links parent_student_links_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_student_links
    ADD CONSTRAINT parent_student_links_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: parent_student_links parent_student_links_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.parent_student_links
    ADD CONSTRAINT parent_student_links_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: results results_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.results
    ADD CONSTRAINT results_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- Name: results results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.results
    ADD CONSTRAINT results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: roadmap_milestones roadmap_milestones_roadmap_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_milestones
    ADD CONSTRAINT roadmap_milestones_roadmap_id_fkey FOREIGN KEY (roadmap_id) REFERENCES public.roadmaps(id) ON DELETE CASCADE;


--
-- Name: roadmap_milestones roadmap_milestones_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmap_milestones
    ADD CONSTRAINT roadmap_milestones_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id);


--
-- Name: roadmaps roadmaps_career_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmaps
    ADD CONSTRAINT roadmaps_career_id_fkey FOREIGN KEY (career_id) REFERENCES public.careers(id);


--
-- Name: roadmaps roadmaps_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roadmaps
    ADD CONSTRAINT roadmaps_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_mentor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_mentor_id_fkey FOREIGN KEY (mentor_id) REFERENCES public.mentors(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: student_insights student_insights_recommended_career_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.student_insights
    ADD CONSTRAINT student_insights_recommended_career_id_fkey FOREIGN KEY (recommended_career_id) REFERENCES public.careers(id);


--
-- Name: student_insights student_insights_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.student_insights
    ADD CONSTRAINT student_insights_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_skills user_skills_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_skills
    ADD CONSTRAINT user_skills_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skills(id) ON DELETE CASCADE;


--
-- Name: user_skills user_skills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.user_skills
    ADD CONSTRAINT user_skills_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 0lHH4PlsWEl9rsTYqwBwMKffvR6LkMj0cBVfs4OjZuZpBf6BebDvtP8hGULFe5b

