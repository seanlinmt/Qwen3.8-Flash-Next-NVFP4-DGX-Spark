#!/usr/bin/env bash
# Start Qwen3.8-Flash-Next TP2 across AI1 (head) and AI2 (worker) on port 8888
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
WORKER_HOST="${WORKER_HOST:-ai2}"

echo "============================================================"
echo " Starting Qwen3.8-Flash-Next NVFP4 TP=2 Cluster"
echo " Head   : AI1 (192.168.177.11) rank 0"
echo " Worker : $WORKER_HOST (192.168.177.12) rank 1"
echo " RoCE   : rocep1s0f0 + roceP2p1s0f0 (dual HCA merging enabled)"
echo "============================================================"

echo "=== 1. Starting Rank 1 worker on $WORKER_HOST ==="
ssh -o BatchMode=yes "$WORKER_HOST" "bash '$SCRIPT_DIR/qwen38fn-nvidia-tp2.sh' 1"

echo "=== Waiting 5 seconds for worker process to establish listener ==="
sleep 5

echo "=== 2. Starting Rank 0 head on local node ==="
bash "$SCRIPT_DIR/qwen38fn-nvidia-tp2.sh" 0
