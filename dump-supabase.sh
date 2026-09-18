#!/usr/bin/env bash
# Puxa schema, RLS/policies/functions, edge functions e storage buckets do Supabase.
# Usa `db dump` (lê o banco direto) em vez de `db pull` (depende do histórico de migrations).
# Uso:  bash dump-supabase.sh
# Rode de dentro de ~/Documents/usfit/scrapingContent, com o projeto já linkado.

set -uo pipefail   # sem -e: um dump que falhe não derruba os outros

command -v supabase >/dev/null || { echo "supabase CLI não encontrada."; exit 1; }

mkdir -p supabase/schema supabase/functions

echo "=== 1/5 schema public (tabelas, indices, constraints, enums, functions, triggers, RLS) ==="
supabase db dump -f supabase/schema/public.sql --schema public

echo "=== 2/5 schema storage ==="
supabase db dump -f supabase/schema/storage.sql --schema storage

echo "=== 3/5 roles ==="
supabase db dump -f supabase/schema/roles.sql --role-only

echo "=== 4/5 storage buckets (dados) ==="
supabase db dump -f supabase/schema/storage_buckets.sql --data-only --schema storage

echo "=== 5/5 edge functions ==="
supabase functions list
for fn in $(supabase functions list 2>/dev/null | awk -F'│' 'NR>3 {gsub(/ /,"",$3); print $3}' | grep -E '^[a-zA-Z0-9_-]+$'); do
  echo ">> baixando: $fn"
  supabase functions download "$fn"
done

echo
echo "--- gerado ---"
find supabase -type f -not -path '*/node_modules/*' | sort
