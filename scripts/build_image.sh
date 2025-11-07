#!/usr/bin/env bash
# 该脚本用于构建包含 AFL+IJON 依赖的 Docker 镜像

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
IMAGE_TAG="${1:-reproduce-ijon:latest}"

echo "[INFO] Building Docker image ${IMAGE_TAG}"
docker build -f "${REPO_ROOT}/docker/Dockerfile" -t "${IMAGE_TAG}" "${REPO_ROOT}"

echo "[INFO] Docker image ${IMAGE_TAG} is ready"
