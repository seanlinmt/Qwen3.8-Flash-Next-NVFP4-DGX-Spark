#!/usr/bin/env bash
# Stop Qwen3.8-Flash-Next TP2 containers on both nodes (AI1 head, AI2 worker)
# and clean up memory/caches.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONTAINER_NAMES=("vllm_qwen38fn" "sglang_qwen38fn")
WORKER_HOST="${WORKER_HOST:-ai2}"

echo "=== Stopping containers on worker node ($WORKER_HOST) ==="
ssh -o BatchMode=yes -o ConnectTimeout=5 "$WORKER_HOST" "
  docker rm -f ${CONTAINER_NAMES[*]} 2>/dev/null || true
  sync
  echo 3 | sudo -n tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
" || echo "Warning: Failed to reach or stop containers on $WORKER_HOST"

echo "=== Stopping containers on local head node ==="
docker rm -f "${CONTAINER_NAMES[@]}" 2>/dev/null || true
sync
echo 3 | sudo -n tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true

echo "=== Status Check ==="
echo "Local node (AI1):"
docker ps --filter "name=qwen38fn"
echo "Worker node ($WORKER_HOST):"
ssh -o BatchMode=yes "$WORKER_HOST" "docker ps --filter 'name=qwen38fn'" || true

echo "Done. All Qwen3.8-Flash-Next containers stopped and caches freed."
