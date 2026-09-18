#!/usr/bin/env bash
# Puxa schema, RLS/policies/functions, edge functions e storage buckets do Supabase
# Uso:  ./pull-supabase.sh <PROJECT_REF>
# Rode de dentro de ~/Documents/usfit/scrapingContent

set -euo pipefail

REF="${1:-}"
if [ -z "$REF" ]; then
  echo "uso: $0 <PROJECT_REF>   (o ref aparece na URL do dashboard: /project/<REF>)"
  exit 1
fi

command -v supabase >/dev/null || { echo "supabase CLI não encontrada. brew install supabase/tap/supabase"; exit 1; }

# 1) init + link
[ -f supabase/config.toml ] || supabase init
supabase login   # abre o browser; pula se já estiver logado
supabase link --project-ref "$REF"

# 2) Schema + RLS + policies + functions + triggers
#    db pull gera supabase/migrations/<timestamp>_remote_schema.sql
supabase db pull --schema public,storage,auth || supabase db pull

# 3) Dump separado, legível, só do schema (sem dados)
mkdir -p supabase/schema
supabase db dump -f supabase/schema/public.sql   --schema public
supabase db dump -f supabase/schema/storage.sql  --schema storage  || true

# 4) RLS/policies explícitos (ficam no dump acima, mas isolar ajuda a revisar)
supabase db dump -f supabase/schema/roles.sql --role-only || true

# 5) Storage buckets (config fica em linhas da tabela storage.buckets)
supabase db dump -f supabase/schema/storage_buckets.sql --data-only --schema storage || true

# 6) Edge Functions
mkdir -p supabase/functions
echo "--- edge functions no projeto ---"
supabase functions list || true
for fn in $(supabase functions list 2>/dev/null | awk 'NR>2 {print $3}' | grep -E '^[a-zA-Z0-9_-]+$' || true); do
  echo ">> baixando function: $fn"
  supabase functions download "$fn" || true
done

echo
echo "pronto. gerado:"
find supabase -type f -not -path '*/node_modules/*' | sort
