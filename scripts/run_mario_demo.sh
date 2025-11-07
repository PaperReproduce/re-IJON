#!/usr/bin/env bash
# 在 reproduce-ijon-mario 容器中重放 1-1 payload 进行快速检查

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "[ERROR] Usage: $0 [image-tag]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
IMAGE_TAG="${1:-reproduce-ijon-mario:latest}"
ROM_PATH="${REPO_ROOT}/external/mario/roms/mario.nes"

if [[ ! -f "$ROM_PATH" ]]; then
  echo "[ERROR] ROM missing: run ./scripts/build_mario_image.sh --rom /path/to/ROM first" >&2
  exit 1
fi

echo "[INFO] Running Mario demo inside ${IMAGE_TAG}"
docker run --rm "${IMAGE_TAG}" bash -lc \
  "cd /workspace/mario && ./build_ijon/smbc_ijon 0 trace < payloads/1-1 | head -n 20"
echo "[INFO] Demo finished"
