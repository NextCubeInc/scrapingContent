SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict qmI9twcSHhPijTCm1mOEoJgqnfryVoOs8a5PXXDI8FPeKcnOa8URHseSD863nA1

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type", "versioning_status") VALUES
	('videos-temp', 'videos-temp', NULL, '2026-09-16 13:13:35.986981+00', '2026-09-16 13:13:35.986981+00', false, false, NULL, NULL, NULL, 'STANDARD', 'DISABLED'),
	('videos-referencia', 'videos-referencia', NULL, '2026-09-16 13:13:35.986981+00', '2026-09-16 13:13:35.986981+00', false, false, NULL, NULL, NULL, 'STANDARD', 'DISABLED');


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- PostgreSQL database dump complete
--

-- \unrestrict qmI9twcSHhPijTCm1mOEoJgqnfryVoOs8a5PXXDI8FPeKcnOa8URHseSD863nA1

RESET ALL;
