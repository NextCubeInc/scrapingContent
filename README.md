# scrapingContent — Supabase

Espelho do projeto Supabase `oxdvslxidnrjboljhuqs`, extraído em 18/09/2026.

## Estrutura

```
supabase/
  schema/
    public.sql             # 16 tabelas, 3 views, 16 FKs, 6 índices
    storage.sql            # schema storage do Supabase
    storage_buckets.sql    # linhas de storage.buckets (config dos buckets)
    roles.sql              # roles do banco
  functions/
    research-profile/
      index.ts             # edge function
  config.toml
```

## Tabelas (`public`)

Monitoramento de perfis e análise de conteúdo:

| Tabela | Papel |
|---|---|
| `perfis_monitorados` | perfis acompanhados |
| `perfil_snapshots` | estado do perfil ao longo do tempo |
| `posts_analisados` | posts coletados |
| `analise_conteudo` | análise do conteúdo do post |
| `analise_criativo` | análise do criativo |
| `analise_edicao` | análise da edição |
| `metricas` | métricas por post |
| `ideias` / `ideia_versoes` | ideias de conteúdo e suas versões |
| `briefings_video` | briefing de produção |
| `publicacoes` | publicações feitas |
| `pos_mortem` | retrospectiva pós-publicação |
| `feedbacks` | feedback recebido |
| `preferencias_aprendidas` / `preferencia_historico` | preferências aprendidas e histórico |
| `relatorios` | relatórios gerados |

Views: `metricas_atuais`, `baseline_perfil`, `videos_para_limpar`.

## Storage

Buckets: `videos-temp`, `videos-referencia`.

## Segurança — atenção

RLS está **habilitado nas 16 tabelas** e **não existe nenhuma policy**. Na prática
só a `service_role` (que ignora RLS) lê ou escreve; `anon` e `authenticated`
recebem resultado vazio em qualquer query.

Isso é correto e seguro se o acesso for sempre por backend com a service key.
Se algum dia o app for ler direto do client, é preciso criar policies antes.

## Edge function

`research-profile` — recebe `POST { "user_name": "<perfil>" }`, valida contra
`/^[a-zA-Z0-9._-]{1,100}$/` e repassa para a API de dataset do Bright Data,
devolvendo a resposta crua.

Requer o secret `BRIGHTDATA_API_KEY` no projeto:

```bash
supabase secrets set BRIGHTDATA_API_KEY=...
```

Deploy:

```bash
supabase functions deploy research-profile
```

## Reextrair do remoto

```bash
supabase link --project-ref oxdvslxidnrjboljhuqs
bash dump-supabase.sh
```

O `dump-supabase.sh` usa `supabase db dump`, que lê o banco direto e não depende
do histórico de migrations — por isso não esbarra no descompasso entre
`supabase_migrations.schema_migrations` do remoto e a pasta `supabase/migrations`
local, que faz o `supabase db pull` falhar neste repo.
