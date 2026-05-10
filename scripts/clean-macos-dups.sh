#!/usr/bin/env bash
# Remove duplicados macOS com sufixos " 2", " 3", " 4" (files e dirs) do workspace.
#
# CAUSA RAIZ DESCONHECIDA. Hipóteses refutadas em 2026-05-10:
#   - iCloud Drive: brctl status nega gerenciamento desta zona
#   - Time Machine: tmutil destinationinfo retorna "No destinations"
#   - APFS auto-snapshots rotativos: só 1 snapshot estático (OS update)
# Hipóteses pendentes: file watcher de IDE, daemon de cloud sync exotic,
# yarn extract concurrent, gulp watch órfão. Instrumentar com fs_usage SE
# os duplicados regenerarem após este script.
#
# Padrão observado: duplicados aparecem em pastas que o gradle build ESCREVE
# (build/, node_modules/.bin/, bundles/osgi/war/), nunca em pastas read-only.
# Permissões dos duplicados são `rw-------@` (mais restritas) vs `rw-r--r--@`
# dos originais — pista pra identificar agente futuramente.
#
# Uso: ./scripts/clean-macos-dups.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$REPO/workspace"

if [ ! -d "$WORKSPACE" ]; then
    echo "ERRO: workspace/ não encontrado em $REPO" >&2
    exit 1
fi

count_before=$(find "$WORKSPACE" \
    \( -name "* 2" -o -name "* 3" -o -name "* 4" \
       -o -name "* 2.*" -o -name "* 3.*" -o -name "* 4.*" \) 2>/dev/null | wc -l | tr -d ' ')

echo "Duplicados encontrados: $count_before"

if [ "$count_before" -eq 0 ]; then
    echo "✅ Workspace limpo, nada a fazer"
    exit 0
fi

find "$WORKSPACE" \
    \( -name "* 2" -o -name "* 3" -o -name "* 4" \
       -o -name "* 2.*" -o -name "* 3.*" -o -name "* 4.*" \) \
    -depth -delete 2>/dev/null

count_after=$(find "$WORKSPACE" \
    \( -name "* 2" -o -name "* 3" -o -name "* 4" \
       -o -name "* 2.*" -o -name "* 3.*" -o -name "* 4.*" \) 2>/dev/null | wc -l | tr -d ' ')

echo "Removidos: $((count_before - count_after))"

if [ "$count_after" -eq 0 ]; then
    echo "✅ Workspace limpo"
else
    echo "⚠️  $count_after duplicados resistiram (provável conflito de permissão — checar manualmente)"
    exit 1
fi
