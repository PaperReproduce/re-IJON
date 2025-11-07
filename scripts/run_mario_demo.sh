#!/usr/bin/env bash
# 在 reproduce-ijon-mario 容器中启动一个短时间的 fuzz demo（不使用 payloads/1-1）

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

DEMO_SECONDS="${DEMO_SECONDS:-20}"

echo "[INFO] Running Mario fuzz demo inside ${IMAGE_TAG} (timeout ${DEMO_SECONDS}s)"
docker run --rm --privileged "${IMAGE_TAG}" bash -lc "
set -euo pipefail
cd /workspace/mario
# 确保 core dump 直接写文件，避免 AFL 报错
if [ -w /proc/sys/kernel/core_pattern ]; then
  echo core > /proc/sys/kernel/core_pattern
fi
WORKDIR=/tmp/mario_fuzz_demo
IN_DIR=\${WORKDIR}/in
OUT_DIR=\${WORKDIR}/out
rm -rf \${WORKDIR}
mkdir -p \${IN_DIR} \${OUT_DIR}
cp seed/a \${IN_DIR}/seed
export AFL_SKIP_CPUFREQ=1 AFL_IJON=1 AFL_I_DONT_CARE_ABOUT_COREDUMPS=1 AFL_I_DONT_CARE_ABOUT_CRASHES=1
timeout ${DEMO_SECONDS}s /workspace/repos/ijon/afl-fuzz -m none -S demo_ijon -i \${IN_DIR} -o \${OUT_DIR} -- ./build_ijon/smbc_ijon 0 >/tmp/mario_fuzz.log 2>&1 || true
if [ -f \${OUT_DIR}/demo_ijon/fuzzer_stats ]; then
  tail -n 10 \${OUT_DIR}/demo_ijon/fuzzer_stats
else
  echo '[WARN] fuzzer_stats missing, dumping AFL log:'
  tail -n 20 /tmp/mario_fuzz.log
fi
"
echo "[INFO] Demo finished"
