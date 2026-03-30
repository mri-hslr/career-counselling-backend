--
-- PostgreSQL database dump
--

\restrict kVqomubmHdU2NM2NA5Fv55uqgIm1HKvzWnkMpVVKQPbjKYkuXtwSZ6VC3U4NeE0

-- Dumped from database version 17.8 (a284a84)
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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO neondb_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: neondb_owner
--

COMMENT ON SCHEMA public IS '';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: userrole; Type: TYPE; Schema: public; Owner: neondb_owner
--

CREATE TYPE public.userrole AS ENUM (
    'student',
    'mentor',
    'parent',
    'admin'
);


ALTER TYPE public.userrole OWNER TO neondb_owner;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Todo; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public."Todo" (
    id integer NOT NULL,
    title text NOT NULL,
    status boolean NOT NULL,
    description text NOT NULL
);


ALTER TABLE public."Todo" OWNER TO neondb_owner;

--
-- Name: Todo_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public."Todo_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Todo_id_seq" OWNER TO neondb_owner;

--
-- Name: Todo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public."Todo_id_seq" OWNED BY public."Todo".id;


--
-- Name: User; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public."User" (
    id integer NOT NULL,
    name text NOT NULL,
    age integer NOT NULL
);


ALTER TABLE public."User" OWNER TO neondb_owner;

--
-- Name: User_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public."User_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."User_id_seq" OWNER TO neondb_owner;

--
-- Name: User_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public."User_id_seq" OWNED BY public."User".id;


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO neondb_owner;

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
-- Name: appointments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.appointments (
    appointment_id integer,
    patient_id integer,
    doctor_id integer
);


ALTER TABLE public.appointments OWNER TO neondb_owner;

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
-- Name: authors; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.authors (
    author_id integer,
    name character varying(120)
);


ALTER TABLE public.authors OWNER TO neondb_owner;

--
-- Name: barca; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.barca (
    losses integer
);


ALTER TABLE public.barca OWNER TO neondb_owner;

--
-- Name: bfbf; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.bfbf (
    age character varying
);


ALTER TABLE public.bfbf OWNER TO neondb_owner;

--
-- Name: bnbn; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.bnbn (
    age character varying
);


ALTER TABLE public.bnbn OWNER TO neondb_owner;

--
-- Name: career_interest; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.career_interest (
    id uuid NOT NULL,
    user_id uuid,
    work_environment text DEFAULT 'Do you prefer a quiet office or a dynamic outdoor field?'::text,
    work_style text DEFAULT 'Do you prefer leading a team or working independently?'::text,
    biggest_strength text DEFAULT 'What is your core personality strength?'::text,
    biggest_weakness text DEFAULT 'What is an area you wish to improve in your behavior?'::text,
    updated_at timestamp with time zone,
    preferred_activity text,
    interest_domain text,
    leadership text,
    helping_nature text,
    data_orientation text,
    creativity text,
    research_inclination text,
    physical_activity text,
    preferred_career_type text,
    career_awareness text,
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.career_interest OWNER TO neondb_owner;

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
-- Name: cdcd; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cdcd (
    age character varying
);


ALTER TABLE public.cdcd OWNER TO neondb_owner;

--
-- Name: cfcf; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cfcf (
    name character varying,
    email character varying
);


ALTER TABLE public.cfcf OWNER TO neondb_owner;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.chat_messages (
    id uuid NOT NULL,
    session_id uuid,
    sender_id uuid,
    message text NOT NULL,
    sent_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.chat_messages OWNER TO neondb_owner;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.comments (
    comment_id integer,
    post_id integer,
    body text
);


ALTER TABLE public.comments OWNER TO neondb_owner;

--
-- Name: cvcv; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cvcv (
    age character varying
);


ALTER TABLE public.cvcv OWNER TO neondb_owner;

--
-- Name: datacenter; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.datacenter (
    dc_id integer NOT NULL,
    username text NOT NULL,
    table_id text NOT NULL,
    schema_data jsonb NOT NULL
);


ALTER TABLE public.datacenter OWNER TO neondb_owner;

--
-- Name: datacenter_dc_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.datacenter_dc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.datacenter_dc_id_seq OWNER TO neondb_owner;

--
-- Name: datacenter_dc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.datacenter_dc_id_seq OWNED BY public.datacenter.dc_id;


--
-- Name: diagram_shares; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.diagram_shares (
    id integer NOT NULL,
    diagram_id integer,
    user_id integer,
    role_id integer,
    granted_by integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.diagram_shares OWNER TO neondb_owner;

--
-- Name: diagram_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.diagram_shares_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagram_shares_id_seq OWNER TO neondb_owner;

--
-- Name: diagram_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.diagram_shares_id_seq OWNED BY public.diagram_shares.id;


--
-- Name: diagrams; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.diagrams (
    id integer NOT NULL,
    owner_id integer,
    title text,
    data jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.diagrams OWNER TO neondb_owner;

--
-- Name: diagrams_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.diagrams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagrams_id_seq OWNER TO neondb_owner;

--
-- Name: diagrams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.diagrams_id_seq OWNED BY public.diagrams.id;


--
-- Name: doctors; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.doctors (
    doctor_id integer,
    doctor_name character varying(150)
);


ALTER TABLE public.doctors OWNER TO neondb_owner;

--
-- Name: dort; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.dort (
    name character varying
);


ALTER TABLE public.dort OWNER TO neondb_owner;

--
-- Name: feedback; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.feedback (
    id integer NOT NULL,
    text character varying(255)
);


ALTER TABLE public.feedback OWNER TO neondb_owner;

--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feedback_id_seq OWNER TO neondb_owner;

--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;


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
-- Name: fr2; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.fr2 (
    name character varying,
    email character varying
);


ALTER TABLE public.fr2 OWNER TO neondb_owner;

--
-- Name: fr3; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.fr3 (
    name character varying,
    email character varying,
    rollno integer
);


ALTER TABLE public.fr3 OWNER TO neondb_owner;

--
-- Name: fr4; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.fr4 (
    age character varying,
    email character varying
);


ALTER TABLE public.fr4 OWNER TO neondb_owner;

--
-- Name: frr; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.frr (
    name character varying
);


ALTER TABLE public.frr OWNER TO neondb_owner;

--
-- Name: global_cache; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.global_cache (
    cache_key text NOT NULL,
    data jsonb NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.global_cache OWNER TO neondb_owner;

--
-- Name: jiji; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.jiji (
    age integer
);


ALTER TABLE public.jiji OWNER TO neondb_owner;

--
-- Name: kjkj; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.kjkj (
    age character varying
);


ALTER TABLE public.kjkj OWNER TO neondb_owner;

--
-- Name: koko; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.koko (
    age integer
);


ALTER TABLE public.koko OWNER TO neondb_owner;

--
-- Name: l; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.l (
    id text,
    email text,
    created text
);


ALTER TABLE public.l OWNER TO neondb_owner;

--
-- Name: laliga; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.laliga (
    age integer
);


ALTER TABLE public.laliga OWNER TO neondb_owner;

--
-- Name: langchain_pg_embedding; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.langchain_pg_embedding (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    document text,
    cmetadata jsonb
);


ALTER TABLE public.langchain_pg_embedding OWNER TO neondb_owner;

--
-- Name: langchain_pg_embedding_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.langchain_pg_embedding_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.langchain_pg_embedding_id_seq OWNER TO neondb_owner;

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
-- Name: loop; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.loop (
    age integer
);


ALTER TABLE public.loop OWNER TO neondb_owner;

--
-- Name: madrid; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.madrid (
    ucl integer
);


ALTER TABLE public.madrid OWNER TO neondb_owner;

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
    is_verified boolean
);


ALTER TABLE public.mentors OWNER TO neondb_owner;

--
-- Name: mnmn; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.mnmn (
    hi character varying
);


ALTER TABLE public.mnmn OWNER TO neondb_owner;

--
-- Name: naammaikyarakhahai; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.naammaikyarakhahai (
    product_id integer,
    product_name character varying(150),
    price numeric(10,2),
    category character varying(100),
    stock integer,
    supplier_id integer
);


ALTER TABLE public.naammaikyarakhahai OWNER TO neondb_owner;

--
-- Name: nayahu2; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.nayahu2 (
    doctor_id integer,
    doctor_name character varying(150),
    age character varying
);


ALTER TABLE public.nayahu2 OWNER TO neondb_owner;

--
-- Name: nayahujii; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.nayahujii (
    patient_id integer,
    full_name character varying(150),
    naam character varying
);


ALTER TABLE public.nayahujii OWNER TO neondb_owner;

--
-- Name: nhbnhb; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.nhbnhb (
    age integer
);


ALTER TABLE public.nhbnhb OWNER TO neondb_owner;

--
-- Name: nhnh; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.nhnh (
    age integer,
    namam character varying,
    ji character varying,
    jiji character varying
);


ALTER TABLE public.nhnh OWNER TO neondb_owner;

--
-- Name: o; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.o (
    orderid text,
    userid text,
    total text
);


ALTER TABLE public.o OWNER TO neondb_owner;

--
-- Name: occupations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.occupations (
    id integer NOT NULL,
    title text NOT NULL,
    moulded_description text,
    embedding public.vector(384)
);


ALTER TABLE public.occupations OWNER TO neondb_owner;

--
-- Name: occupations_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.occupations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.occupations_id_seq OWNER TO neondb_owner;

--
-- Name: occupations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.occupations_id_seq OWNED BY public.occupations.id;


--
-- Name: office; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.office (
    id integer
);


ALTER TABLE public.office OWNER TO neondb_owner;

--
-- Name: oioioi; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.oioioi (
    age integer
);


ALTER TABLE public.oioioi OWNER TO neondb_owner;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.orders (
    orderid text,
    userid text,
    total text
);


ALTER TABLE public.orders OWNER TO neondb_owner;

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
-- Name: passion_strength; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.passion_strength (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    free_time_activity text,
    most_exciting_activity text,
    natural_strength_area text,
    what_people_praise_you_for text,
    confidence_trigger text,
    biggest_strength text,
    biggest_weakness text,
    effort_level text,
    motivation_driver text,
    easiest_tasks text,
    most_satisfying_success text,
    curiosity_level text,
    updated_at timestamp with time zone DEFAULT now(),
    field_configs jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.passion_strength OWNER TO neondb_owner;

--
-- Name: personality_question_bank; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.personality_question_bank (
    id character varying(10) NOT NULL,
    trait character varying(50) NOT NULL,
    sub_trait character varying(100),
    question_text text NOT NULL,
    question_type character varying(10),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT personality_question_bank_question_type_check CHECK (((question_type)::text = ANY ((ARRAY['positive'::character varying, 'negative'::character varying])::text[])))
);


ALTER TABLE public.personality_question_bank OWNER TO neondb_owner;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.posts (
    post_id integer,
    title character varying(250),
    content text
);


ALTER TABLE public.posts OWNER TO neondb_owner;

--
-- Name: products; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.products (
    pid text,
    name text,
    price text
);


ALTER TABLE public.products OWNER TO neondb_owner;

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
-- Name: ref_profile; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.ref_profile (
    id text NOT NULL,
    user_id text NOT NULL,
    personality_score jsonb DEFAULT '{}'::jsonb,
    apti_score jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ref_profile OWNER TO neondb_owner;

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
-- Name: rexrex; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.rexrex (
    name character varying
);


ALTER TABLE public.rexrex OWNER TO neondb_owner;

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
-- Name: roadmaps; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roadmaps (
    id uuid NOT NULL,
    student_id uuid,
    career_id uuid,
    total_months integer,
    generated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.roadmaps OWNER TO neondb_owner;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.roles OWNER TO neondb_owner;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO neondb_owner;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: samarth; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.samarth (
    name character varying
);


ALTER TABLE public.samarth OWNER TO neondb_owner;

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
    meeting_url character varying
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
-- Name: source; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.source (
    diagram_id text NOT NULL,
    user_id text,
    title text,
    state jsonb NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.source OWNER TO neondb_owner;

--
-- Name: student; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.student (
    name character varying,
    age integer
);


ALTER TABLE public.student OWNER TO neondb_owner;

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
-- Name: students; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.students (
    age integer
);


ALTER TABLE public.students OWNER TO neondb_owner;

--
-- Name: tablaa; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.tablaa (
    age character varying
);


ALTER TABLE public.tablaa OWNER TO neondb_owner;

--
-- Name: tablaaaooo; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.tablaaaooo (
    age integer
);


ALTER TABLE public.tablaaaooo OWNER TO neondb_owner;

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
-- Name: uouo; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.uouo (
    age integer,
    name character varying
);


ALTER TABLE public.uouo OWNER TO neondb_owner;

--
-- Name: user2; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.user2 (
    id text,
    email text,
    created text
);


ALTER TABLE public.user2 OWNER TO neondb_owner;

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
    invite_code character varying(6)
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: userssss; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.userssss (
    age integer
);


ALTER TABLE public.userssss OWNER TO neondb_owner;

--
-- Name: vbvb; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.vbvb (
    age character varying
);


ALTER TABLE public.vbvb OWNER TO neondb_owner;

--
-- Name: vgvg; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.vgvg (
    age character varying
);


ALTER TABLE public.vgvg OWNER TO neondb_owner;

--
-- Name: watchers; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.watchers (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.watchers OWNER TO neondb_owner;

--
-- Name: watchers_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.watchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.watchers_id_seq OWNER TO neondb_owner;

--
-- Name: watchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.watchers_id_seq OWNED BY public.watchers.id;


--
-- Name: watchlist; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.watchlist (
    watchlist_id integer NOT NULL,
    user_id integer NOT NULL,
    movie_id integer NOT NULL,
    title character varying(255) NOT NULL,
    media_type character varying(20),
    poster_path text,
    release_date date,
    metadata jsonb,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.watchlist OWNER TO neondb_owner;

--
-- Name: watchlist_watchlist_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.watchlist_watchlist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.watchlist_watchlist_id_seq OWNER TO neondb_owner;

--
-- Name: watchlist_watchlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.watchlist_watchlist_id_seq OWNED BY public.watchlist.watchlist_id;


--
-- Name: xaxa; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.xaxa (
    name character varying,
    email character varying
);


ALTER TABLE public.xaxa OWNER TO neondb_owner;

--
-- Name: xsxs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.xsxs (
    age character varying
);


ALTER TABLE public.xsxs OWNER TO neondb_owner;

--
-- Name: yash; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.yash (
    name character varying
);


ALTER TABLE public.yash OWNER TO neondb_owner;

--
-- Name: yashh; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.yashh (
    name integer,
    age character varying
);


ALTER TABLE public.yashh OWNER TO neondb_owner;

--
-- Name: yashihu; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.yashihu (
    age integer,
    name integer
);


ALTER TABLE public.yashihu OWNER TO neondb_owner;

--
-- Name: yoyoyo; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.yoyoyo (
    age integer
);


ALTER TABLE public.yoyoyo OWNER TO neondb_owner;

--
-- Name: yu; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.yu (
    age integer
);


ALTER TABLE public.yu OWNER TO neondb_owner;

--
-- Name: zhzh; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.zhzh (
    age character varying
);


ALTER TABLE public.zhzh OWNER TO neondb_owner;

--
-- Name: zhzhzh; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.zhzhzh (
    age character varying
);


ALTER TABLE public.zhzhzh OWNER TO neondb_owner;

--
-- Name: Todo id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."Todo" ALTER COLUMN id SET DEFAULT nextval('public."Todo_id_seq"'::regclass);


--
-- Name: User id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."User" ALTER COLUMN id SET DEFAULT nextval('public."User_id_seq"'::regclass);


--
-- Name: datacenter dc_id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.datacenter ALTER COLUMN dc_id SET DEFAULT nextval('public.datacenter_dc_id_seq'::regclass);


--
-- Name: diagram_shares id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagram_shares ALTER COLUMN id SET DEFAULT nextval('public.diagram_shares_id_seq'::regclass);


--
-- Name: diagrams id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagrams ALTER COLUMN id SET DEFAULT nextval('public.diagrams_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);


--
-- Name: occupations id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.occupations ALTER COLUMN id SET DEFAULT nextval('public.occupations_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: watchers id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchers ALTER COLUMN id SET DEFAULT nextval('public.watchers_id_seq'::regclass);


--
-- Name: watchlist watchlist_id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchlist ALTER COLUMN watchlist_id SET DEFAULT nextval('public.watchlist_watchlist_id_seq'::regclass);


--
-- Name: Todo Todo_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."Todo"
    ADD CONSTRAINT "Todo_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


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
-- Name: datacenter datacenter_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.datacenter
    ADD CONSTRAINT datacenter_pkey PRIMARY KEY (dc_id);


--
-- Name: diagram_shares diagram_shares_diagram_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagram_shares
    ADD CONSTRAINT diagram_shares_diagram_id_user_id_key UNIQUE (diagram_id, user_id);


--
-- Name: diagram_shares diagram_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagram_shares
    ADD CONSTRAINT diagram_shares_pkey PRIMARY KEY (id);


--
-- Name: diagrams diagrams_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagrams
    ADD CONSTRAINT diagrams_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


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
-- Name: global_cache global_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.global_cache
    ADD CONSTRAINT global_cache_pkey PRIMARY KEY (cache_key);


--
-- Name: langchain_pg_embedding langchain_pg_embedding_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.langchain_pg_embedding
    ADD CONSTRAINT langchain_pg_embedding_pkey PRIMARY KEY (id);


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
-- Name: occupations occupations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.occupations
    ADD CONSTRAINT occupations_pkey PRIMARY KEY (id);


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
-- Name: passion_strength passion_strength_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.passion_strength
    ADD CONSTRAINT passion_strength_pkey PRIMARY KEY (id);


--
-- Name: personality_question_bank personality_question_bank_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.personality_question_bank
    ADD CONSTRAINT personality_question_bank_pkey PRIMARY KEY (id);


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
-- Name: career_interest psychometric_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_interest
    ADD CONSTRAINT psychometric_profiles_pkey PRIMARY KEY (id);


--
-- Name: career_interest psychometric_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_interest
    ADD CONSTRAINT psychometric_profiles_user_id_key UNIQUE (user_id);


--
-- Name: ref_profile ref_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ref_profile
    ADD CONSTRAINT ref_profile_pkey PRIMARY KEY (id);


--
-- Name: ref_profile ref_profile_user_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.ref_profile
    ADD CONSTRAINT ref_profile_user_id_key UNIQUE (user_id);


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
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


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
-- Name: source source_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT source_pkey PRIMARY KEY (diagram_id);


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
-- Name: watchers watchers_email_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_email_key UNIQUE (email);


--
-- Name: watchers watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_pkey PRIMARY KEY (id);


--
-- Name: watchlist watchlist_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchlist
    ADD CONSTRAINT watchlist_pkey PRIMARY KEY (watchlist_id);


--
-- Name: watchlist watchlist_user_id_movie_id_key; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.watchlist
    ADD CONSTRAINT watchlist_user_id_movie_id_key UNIQUE (user_id, movie_id);


--
-- Name: idx_metadata_query; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_metadata_query ON public.langchain_pg_embedding USING gin (cmetadata);


--
-- Name: idx_personality_trait; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX idx_personality_trait ON public.personality_question_bank USING btree (trait);


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
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: diagram_shares diagram_shares_diagram_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagram_shares
    ADD CONSTRAINT diagram_shares_diagram_id_fkey FOREIGN KEY (diagram_id) REFERENCES public.diagrams(id) ON DELETE CASCADE;


--
-- Name: diagram_shares diagram_shares_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.diagram_shares
    ADD CONSTRAINT diagram_shares_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: financial_profiles financial_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.financial_profiles
    ADD CONSTRAINT financial_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: passion_strength passion_strength_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.passion_strength
    ADD CONSTRAINT passion_strength_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: career_interest psychometric_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.career_interest
    ADD CONSTRAINT psychometric_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: neondb_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO neon_superuser WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: cloud_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE cloud_admin IN SCHEMA public GRANT ALL ON TABLES TO neon_superuser WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

\unrestrict kVqomubmHdU2NM2NA5Fv55uqgIm1HKvzWnkMpVVKQPbjKYkuXtwSZ6VC3U4NeE0

