


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."analise_conteudo" (
    "post_id" "uuid" NOT NULL,
    "tema_central" "text",
    "subtema" "text",
    "nivel_funil" "text",
    "promessa" "text",
    "dor_abordada" "text",
    "publico_provavel" "text",
    "cta" "text",
    "analisado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "analise_conteudo_nivel_funil_check" CHECK (("nivel_funil" = ANY (ARRAY['topo_amplo'::"text", 'educacional_qualificado'::"text", 'autoridade'::"text", 'conversao'::"text"])))
);


ALTER TABLE "public"."analise_conteudo" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."analise_criativo" (
    "post_id" "uuid" NOT NULL,
    "gancho" "text",
    "primeiros_segundos" "text",
    "formato" "text",
    "demonstracao" "text",
    "cenario" "text",
    "estrutura_narrativa" "text",
    "ritmo" "text",
    "analisado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."analise_criativo" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."analise_edicao" (
    "post_id" "uuid" NOT NULL,
    "textos_tela" "text"[],
    "cortes" integer,
    "ritmo_troca_cena" numeric,
    "usa_zoom" boolean,
    "usa_broll" boolean,
    "usa_comparacao" boolean,
    "destaque_visual" "text",
    "legenda_embutida" boolean,
    "analisado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."analise_edicao" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."metricas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "post_id" "uuid" NOT NULL,
    "views" bigint,
    "curtidas" bigint,
    "comentarios" bigint,
    "compartilh" bigint,
    "salvamentos" bigint,
    "indisponivel" "text",
    "coletado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."metricas" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."metricas_atuais" WITH ("security_invoker"='true') AS
 SELECT DISTINCT ON ("post_id") "post_id",
    "views",
    "curtidas",
    "comentarios",
    "compartilh",
    "salvamentos",
    "indisponivel",
    "coletado_em"
   FROM "public"."metricas"
  ORDER BY "post_id", "coletado_em" DESC;


ALTER VIEW "public"."metricas_atuais" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."posts_analisados" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "perfil_id" "uuid" NOT NULL,
    "url" "text" NOT NULL,
    "shortcode" "text",
    "tipo" "text",
    "data_publicacao" timestamp with time zone,
    "duracao_segundos" numeric,
    "legenda" "text",
    "hashtags" "text"[],
    "coletado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "posts_analisados_tipo_check" CHECK (("tipo" = ANY (ARRAY['reel'::"text", 'post'::"text", 'carrossel'::"text", 'story'::"text"])))
);


ALTER TABLE "public"."posts_analisados" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."baseline_perfil" WITH ("security_invoker"='true') AS
 SELECT "p"."perfil_id",
    "count"(*) AS "n_posts",
    "percentile_cont"((0.5)::double precision) WITHIN GROUP (ORDER BY (("m"."views")::double precision)) AS "mediana_views",
    "percentile_cont"((0.5)::double precision) WITHIN GROUP (ORDER BY (("m"."curtidas")::double precision)) AS "mediana_curtidas"
   FROM ("public"."posts_analisados" "p"
     JOIN "public"."metricas_atuais" "m" ON (("m"."post_id" = "p"."id")))
  WHERE (("p"."data_publicacao" > ("now"() - '90 days'::interval)) AND ("m"."views" IS NOT NULL))
  GROUP BY "p"."perfil_id";


ALTER VIEW "public"."baseline_perfil" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."briefings_video" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "post_id" "uuid" NOT NULL,
    "nota" smallint,
    "justificativa_nota" "text" NOT NULL,
    "classificacao_funil" "text",
    "transferivel" boolean,
    "motivo_nao_transfer" "text",
    "padroes" "text"[],
    "resumo" "text",
    "video_status" "text" DEFAULT 'temp'::"text" NOT NULL,
    "video_path" "text",
    "analisado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "briefings_video_classificacao_funil_check" CHECK (("classificacao_funil" = ANY (ARRAY['topo_amplo'::"text", 'educacional_qualificado'::"text", 'autoridade'::"text", 'conversao'::"text"]))),
    CONSTRAINT "briefings_video_nota_check" CHECK ((("nota" >= 1) AND ("nota" <= 5))),
    CONSTRAINT "briefings_video_video_status_check" CHECK (("video_status" = ANY (ARRAY['temp'::"text", 'referencia'::"text", 'removido'::"text"])))
);


ALTER TABLE "public"."briefings_video" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."feedbacks" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ideia_id" "uuid",
    "acao" "text" NOT NULL,
    "motivo" "text",
    "texto_livre" "text",
    "escopo" "text" DEFAULT 'permanente'::"text" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "feedbacks_acao_check" CHECK (("acao" = ANY (ARRAY['aprovar'::"text", 'rejeitar'::"text", 'adaptar'::"text", 'publicar'::"text", 'corrigir_regra'::"text"]))),
    CONSTRAINT "feedbacks_escopo_check" CHECK (("escopo" = ANY (ARRAY['permanente'::"text", 'pontual'::"text"])))
);


ALTER TABLE "public"."feedbacks" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ideia_versoes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ideia_id" "uuid" NOT NULL,
    "versao" integer NOT NULL,
    "snapshot" "jsonb" NOT NULL,
    "motivo" "text",
    "criada_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."ideia_versoes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ideias" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "titulo_interno" "text" NOT NULL,
    "objetivo" "text" NOT NULL,
    "local" "text",
    "referencia_post" "uuid",
    "elemento_aproveitado" "text",
    "por_que_gravar" "text" NOT NULL,
    "gancho" "text" NOT NULL,
    "roteiro" "text" NOT NULL,
    "textos_tela" "jsonb" DEFAULT '[]'::"jsonb" NOT NULL,
    "edicao" "text",
    "cta" "text",
    "status" "text" DEFAULT 'pendente'::"text" NOT NULL,
    "adaptada_de" "uuid",
    "substitui" "uuid",
    "revisao_pt_ok" boolean DEFAULT false NOT NULL,
    "lote" "date",
    "criada_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "ideias_status_check" CHECK (("status" = ANY (ARRAY['pendente'::"text", 'aprovada'::"text", 'rejeitada'::"text", 'adaptada'::"text", 'publicada'::"text"])))
);


ALTER TABLE "public"."ideias" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."perfil_snapshots" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "perfil_id" "uuid" NOT NULL,
    "seguidores" bigint,
    "total_posts" bigint,
    "indisponivel" "text",
    "coletado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."perfil_snapshots" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."perfis_monitorados" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "handle" "text" NOT NULL,
    "url" "text" NOT NULL,
    "tipo" "text" NOT NULL,
    "status" "text" DEFAULT 'ativo'::"text" NOT NULL,
    "observacoes" "text",
    "data_inclusao" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "perfis_monitorados_status_check" CHECK (("status" = ANY (ARRAY['ativo'::"text", 'pausado'::"text"]))),
    CONSTRAINT "perfis_monitorados_tipo_check" CHECK (("tipo" = ANY (ARRAY['proprio'::"text", 'referencia'::"text"])))
);


ALTER TABLE "public"."perfis_monitorados" OWNER TO "postgres";


COMMENT ON COLUMN "public"."perfis_monitorados"."tipo" IS 'proprio = perfil do Ícaro; referencia = concorrente/inspiração';



CREATE TABLE IF NOT EXISTS "public"."pos_mortem" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "publicacao_id" "uuid" NOT NULL,
    "vs_baseline" numeric,
    "provavel_ajudou" "text",
    "nao_funcionou" "text",
    "hipotese_proximo" "text",
    "nivel_evidencia" "text" DEFAULT 'hipotese'::"text" NOT NULL,
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "pos_mortem_nivel_evidencia_check" CHECK (("nivel_evidencia" = ANY (ARRAY['hipotese'::"text", 'padrao_repetido'::"text", 'confirmado'::"text"])))
);


ALTER TABLE "public"."pos_mortem" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."preferencia_historico" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "preferencia_id" "uuid" NOT NULL,
    "campo" "text" NOT NULL,
    "valor_antes" "text",
    "valor_depois" "text",
    "motivo" "text",
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."preferencia_historico" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."preferencias_aprendidas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "regra" "text" NOT NULL,
    "dimensao" "text",
    "direcao" "text" NOT NULL,
    "peso" numeric DEFAULT 1.0 NOT NULL,
    "confianca" numeric DEFAULT 0.3 NOT NULL,
    "n_evidencias" integer DEFAULT 1 NOT NULL,
    "origem" "text" NOT NULL,
    "ativa" boolean DEFAULT true NOT NULL,
    "editavel" boolean DEFAULT true NOT NULL,
    "criada_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "atualizada_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "preferencias_aprendidas_confianca_check" CHECK ((("confianca" >= (0)::numeric) AND ("confianca" <= (1)::numeric))),
    CONSTRAINT "preferencias_aprendidas_dimensao_check" CHECK (("dimensao" = ANY (ARRAY['tema'::"text", 'formato'::"text", 'gancho'::"text", 'nivel_tecnico'::"text", 'local'::"text", 'cta'::"text", 'edicao'::"text"]))),
    CONSTRAINT "preferencias_aprendidas_direcao_check" CHECK (("direcao" = ANY (ARRAY['preferir'::"text", 'evitar'::"text"]))),
    CONSTRAINT "preferencias_aprendidas_origem_check" CHECK (("origem" = ANY (ARRAY['feedback_humano'::"text", 'performance'::"text", 'misto'::"text"])))
);


ALTER TABLE "public"."preferencias_aprendidas" OWNER TO "postgres";


COMMENT ON COLUMN "public"."preferencias_aprendidas"."confianca" IS 'Começa baixa. Só sobe com evidência repetida (spec §20: nunca concluir de um post só).';



CREATE TABLE IF NOT EXISTS "public"."publicacoes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ideia_id" "uuid" NOT NULL,
    "post_id" "uuid",
    "url" "text",
    "publicado_em" timestamp with time zone,
    "coleta_em" timestamp with time zone,
    "registrado_em" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."publicacoes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."relatorios" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tipo" "text" DEFAULT 'semanal'::"text" NOT NULL,
    "periodo_inicio" "date" NOT NULL,
    "periodo_fim" "date" NOT NULL,
    "conteudo" "text" NOT NULL,
    "dados" "jsonb",
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "relatorios_tipo_check" CHECK (("tipo" = ANY (ARRAY['semanal'::"text", 'sob_demanda'::"text"])))
);


ALTER TABLE "public"."relatorios" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."videos_para_limpar" WITH ("security_invoker"='true') AS
 SELECT "id",
    "post_id",
    "video_path",
    "nota",
    "analisado_em"
   FROM "public"."briefings_video" "b"
  WHERE (("video_status" = 'temp'::"text") AND ("video_path" IS NOT NULL) AND ("nota" IS NOT NULL) AND ("nota" < 5));


ALTER VIEW "public"."videos_para_limpar" OWNER TO "postgres";


ALTER TABLE ONLY "public"."analise_conteudo"
    ADD CONSTRAINT "analise_conteudo_pkey" PRIMARY KEY ("post_id");



ALTER TABLE ONLY "public"."analise_criativo"
    ADD CONSTRAINT "analise_criativo_pkey" PRIMARY KEY ("post_id");



ALTER TABLE ONLY "public"."analise_edicao"
    ADD CONSTRAINT "analise_edicao_pkey" PRIMARY KEY ("post_id");



ALTER TABLE ONLY "public"."briefings_video"
    ADD CONSTRAINT "briefings_video_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."feedbacks"
    ADD CONSTRAINT "feedbacks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ideia_versoes"
    ADD CONSTRAINT "ideia_versoes_ideia_id_versao_key" UNIQUE ("ideia_id", "versao");



ALTER TABLE ONLY "public"."ideia_versoes"
    ADD CONSTRAINT "ideia_versoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ideias"
    ADD CONSTRAINT "ideias_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."metricas"
    ADD CONSTRAINT "metricas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perfil_snapshots"
    ADD CONSTRAINT "perfil_snapshots_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."perfis_monitorados"
    ADD CONSTRAINT "perfis_monitorados_handle_key" UNIQUE ("handle");



ALTER TABLE ONLY "public"."perfis_monitorados"
    ADD CONSTRAINT "perfis_monitorados_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pos_mortem"
    ADD CONSTRAINT "pos_mortem_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."posts_analisados"
    ADD CONSTRAINT "posts_analisados_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."posts_analisados"
    ADD CONSTRAINT "posts_analisados_url_key" UNIQUE ("url");



ALTER TABLE ONLY "public"."preferencia_historico"
    ADD CONSTRAINT "preferencia_historico_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."preferencias_aprendidas"
    ADD CONSTRAINT "preferencias_aprendidas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."publicacoes"
    ADD CONSTRAINT "publicacoes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."relatorios"
    ADD CONSTRAINT "relatorios_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_briefings_nota" ON "public"."briefings_video" USING "btree" ("nota" DESC, "analisado_em" DESC);



CREATE INDEX "idx_briefings_status" ON "public"."briefings_video" USING "btree" ("video_status");



CREATE INDEX "idx_ideias_lote" ON "public"."ideias" USING "btree" ("lote" DESC);



CREATE INDEX "idx_ideias_status" ON "public"."ideias" USING "btree" ("status", "criada_em" DESC);



CREATE INDEX "idx_metricas_post" ON "public"."metricas" USING "btree" ("post_id", "coletado_em" DESC);



CREATE INDEX "idx_posts_perfil_data" ON "public"."posts_analisados" USING "btree" ("perfil_id", "data_publicacao" DESC);



ALTER TABLE ONLY "public"."analise_conteudo"
    ADD CONSTRAINT "analise_conteudo_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."analise_criativo"
    ADD CONSTRAINT "analise_criativo_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."analise_edicao"
    ADD CONSTRAINT "analise_edicao_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."briefings_video"
    ADD CONSTRAINT "briefings_video_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."feedbacks"
    ADD CONSTRAINT "feedbacks_ideia_id_fkey" FOREIGN KEY ("ideia_id") REFERENCES "public"."ideias"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ideia_versoes"
    ADD CONSTRAINT "ideia_versoes_ideia_id_fkey" FOREIGN KEY ("ideia_id") REFERENCES "public"."ideias"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."ideias"
    ADD CONSTRAINT "ideias_adaptada_de_fkey" FOREIGN KEY ("adaptada_de") REFERENCES "public"."ideias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ideias"
    ADD CONSTRAINT "ideias_referencia_post_fkey" FOREIGN KEY ("referencia_post") REFERENCES "public"."posts_analisados"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."ideias"
    ADD CONSTRAINT "ideias_substitui_fkey" FOREIGN KEY ("substitui") REFERENCES "public"."ideias"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."metricas"
    ADD CONSTRAINT "metricas_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."perfil_snapshots"
    ADD CONSTRAINT "perfil_snapshots_perfil_id_fkey" FOREIGN KEY ("perfil_id") REFERENCES "public"."perfis_monitorados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pos_mortem"
    ADD CONSTRAINT "pos_mortem_publicacao_id_fkey" FOREIGN KEY ("publicacao_id") REFERENCES "public"."publicacoes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."posts_analisados"
    ADD CONSTRAINT "posts_analisados_perfil_id_fkey" FOREIGN KEY ("perfil_id") REFERENCES "public"."perfis_monitorados"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."preferencia_historico"
    ADD CONSTRAINT "preferencia_historico_preferencia_id_fkey" FOREIGN KEY ("preferencia_id") REFERENCES "public"."preferencias_aprendidas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."publicacoes"
    ADD CONSTRAINT "publicacoes_ideia_id_fkey" FOREIGN KEY ("ideia_id") REFERENCES "public"."ideias"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."publicacoes"
    ADD CONSTRAINT "publicacoes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts_analisados"("id") ON DELETE SET NULL;



ALTER TABLE "public"."analise_conteudo" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."analise_criativo" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."analise_edicao" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."briefings_video" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."feedbacks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ideia_versoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ideias" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."metricas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."perfil_snapshots" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."perfis_monitorados" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pos_mortem" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."posts_analisados" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."preferencia_historico" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."preferencias_aprendidas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."publicacoes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."relatorios" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON TABLE "public"."analise_conteudo" TO "anon";
GRANT ALL ON TABLE "public"."analise_conteudo" TO "authenticated";
GRANT ALL ON TABLE "public"."analise_conteudo" TO "service_role";



GRANT ALL ON TABLE "public"."analise_criativo" TO "anon";
GRANT ALL ON TABLE "public"."analise_criativo" TO "authenticated";
GRANT ALL ON TABLE "public"."analise_criativo" TO "service_role";



GRANT ALL ON TABLE "public"."analise_edicao" TO "anon";
GRANT ALL ON TABLE "public"."analise_edicao" TO "authenticated";
GRANT ALL ON TABLE "public"."analise_edicao" TO "service_role";



GRANT ALL ON TABLE "public"."metricas" TO "anon";
GRANT ALL ON TABLE "public"."metricas" TO "authenticated";
GRANT ALL ON TABLE "public"."metricas" TO "service_role";



GRANT ALL ON TABLE "public"."metricas_atuais" TO "anon";
GRANT ALL ON TABLE "public"."metricas_atuais" TO "authenticated";
GRANT ALL ON TABLE "public"."metricas_atuais" TO "service_role";



GRANT ALL ON TABLE "public"."posts_analisados" TO "anon";
GRANT ALL ON TABLE "public"."posts_analisados" TO "authenticated";
GRANT ALL ON TABLE "public"."posts_analisados" TO "service_role";



GRANT ALL ON TABLE "public"."baseline_perfil" TO "anon";
GRANT ALL ON TABLE "public"."baseline_perfil" TO "authenticated";
GRANT ALL ON TABLE "public"."baseline_perfil" TO "service_role";



GRANT ALL ON TABLE "public"."briefings_video" TO "anon";
GRANT ALL ON TABLE "public"."briefings_video" TO "authenticated";
GRANT ALL ON TABLE "public"."briefings_video" TO "service_role";



GRANT ALL ON TABLE "public"."feedbacks" TO "anon";
GRANT ALL ON TABLE "public"."feedbacks" TO "authenticated";
GRANT ALL ON TABLE "public"."feedbacks" TO "service_role";



GRANT ALL ON TABLE "public"."ideia_versoes" TO "anon";
GRANT ALL ON TABLE "public"."ideia_versoes" TO "authenticated";
GRANT ALL ON TABLE "public"."ideia_versoes" TO "service_role";



GRANT ALL ON TABLE "public"."ideias" TO "anon";
GRANT ALL ON TABLE "public"."ideias" TO "authenticated";
GRANT ALL ON TABLE "public"."ideias" TO "service_role";



GRANT ALL ON TABLE "public"."perfil_snapshots" TO "anon";
GRANT ALL ON TABLE "public"."perfil_snapshots" TO "authenticated";
GRANT ALL ON TABLE "public"."perfil_snapshots" TO "service_role";



GRANT ALL ON TABLE "public"."perfis_monitorados" TO "anon";
GRANT ALL ON TABLE "public"."perfis_monitorados" TO "authenticated";
GRANT ALL ON TABLE "public"."perfis_monitorados" TO "service_role";



GRANT ALL ON TABLE "public"."pos_mortem" TO "anon";
GRANT ALL ON TABLE "public"."pos_mortem" TO "authenticated";
GRANT ALL ON TABLE "public"."pos_mortem" TO "service_role";



GRANT ALL ON TABLE "public"."preferencia_historico" TO "anon";
GRANT ALL ON TABLE "public"."preferencia_historico" TO "authenticated";
GRANT ALL ON TABLE "public"."preferencia_historico" TO "service_role";



GRANT ALL ON TABLE "public"."preferencias_aprendidas" TO "anon";
GRANT ALL ON TABLE "public"."preferencias_aprendidas" TO "authenticated";
GRANT ALL ON TABLE "public"."preferencias_aprendidas" TO "service_role";



GRANT ALL ON TABLE "public"."publicacoes" TO "anon";
GRANT ALL ON TABLE "public"."publicacoes" TO "authenticated";
GRANT ALL ON TABLE "public"."publicacoes" TO "service_role";



GRANT ALL ON TABLE "public"."relatorios" TO "anon";
GRANT ALL ON TABLE "public"."relatorios" TO "authenticated";
GRANT ALL ON TABLE "public"."relatorios" TO "service_role";



GRANT ALL ON TABLE "public"."videos_para_limpar" TO "anon";
GRANT ALL ON TABLE "public"."videos_para_limpar" TO "authenticated";
GRANT ALL ON TABLE "public"."videos_para_limpar" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







