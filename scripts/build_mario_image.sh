#!/usr/bin/env bash
# 构建包含 Super Mario 复现环境的专用镜像

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: build_mario_image.sh [--rom /path/to/ROM] [--tag image_name]

--rom  指向本地 Super Mario Bros. (JU) (PRG0) [!].nes 文件；若 external/mario/roms/ 中已有合法 ROM 可省略
--tag  输出镜像名，默认 reproduce-ijon-mario:latest
EOF
  exit 1
}

SCRIPT_DIR="$(cd -- "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
ROM_DST_DIR="${REPO_ROOT}/external/mario/roms"
ROM_DST="${ROM_DST_DIR}/mario.nes"
LEGACY_ROM="${ROM_DST_DIR}/Super Mario Bros. (JU) (PRG0) [!].nes"
IMAGE_TAG="reproduce-ijon-mario:latest"
ROM_SRC=""
EXPECTED_MD5="811b027eaf99c2def7b933c5208636de"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rom)
      [[ $# -ge 2 ]] || usage
      ROM_SRC="$2"
      shift 2
      ;;
    --tag)
      [[ $# -ge 2 ]] || usage
      IMAGE_TAG="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ ! -f "$ROM_DST" && -f "$LEGACY_ROM" ]]; then
  mv "$LEGACY_ROM" "$ROM_DST"
  echo "[INFO] Migrated legacy ROM filename to mario.nes"
fi

if [[ ! -f "$ROM_DST" ]]; then
  if [[ -z "$ROM_SRC" ]]; then
    echo "[ERROR] ROM missing. Provide --rom /path/to/\"Super Mario Bros. (JU) (PRG0) [!].nes\"" >&2
    exit 1
  fi
  if [[ ! -f "$ROM_SRC" ]]; then
    echo "[ERROR] ROM file not found: $ROM_SRC" >&2
    exit 1
  fi
  ACTUAL_MD5="$(md5sum "$ROM_SRC" | awk '{print $1}')"
  if [[ "$ACTUAL_MD5" != "$EXPECTED_MD5" ]]; then
    echo "[ERROR] MD5 mismatch. Expected ${EXPECTED_MD5}, got ${ACTUAL_MD5}" >&2
    exit 1
  fi
  mkdir -p "$ROM_DST_DIR"
  cp "$ROM_SRC" "$ROM_DST"
  echo "[INFO] ROM copied to ${ROM_DST}"
fi

echo "[INFO] Building Mario image ${IMAGE_TAG}"
docker build -f "${REPO_ROOT}/docker/Dockerfile.mario" -t "${IMAGE_TAG}" "${REPO_ROOT}"
echo "[INFO] Mario image ${IMAGE_TAG} is ready"
