#!/usr/bin/env bash
# 该脚本在容器中运行 AFL 的自检以确保编译成功

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "[ERROR] Usage: $0 [image-tag]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
IMAGE_TAG="${1:-reproduce-ijon:latest}"

echo "[INFO] Running AFL self-test inside ${IMAGE_TAG}"
docker run --rm -v "${REPO_ROOT}:/workspace" "${IMAGE_TAG}" \
  bash -lc "cd /workspace/repos/ijon && make test_build"

echo "[INFO] Self-test finished successfully"
