#!/usr/bin/env bash
# Extract fastMRI brain multicoil batch_0 archives into data/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="${ROOT}/data"
ARCHIVES_DIR="${DATA_DIR}/archives"
LOG="${DATA_DIR}/extract.log"

mkdir -p "${DATA_DIR}"
cd "${DATA_DIR}"
exec > >(tee -a "${LOG}") 2>&1

echo "=== fastMRI extract started: $(date -Is) ==="
echo "Extracting into: ${DATA_DIR}"
df -h "${DATA_DIR}" | tail -1

extract() {
  local archive="$1"
  echo ""
  echo ">>> Extracting ${archive} ($(date -Is))"
  tar -xJf "${ARCHIVES_DIR}/${archive}"
  echo "<<< Finished ${archive} ($(date -Is))"
}

# Smallest first for quicker feedback, then val, then train
extract "brain_multicoil_test_batch_0.tar.xz"
extract "brain_multicoil_val_batch_0.tar.xz"
extract "brain_multicoil_train_batch_0.tar.xz"

echo ""
echo "=== fastMRI extract finished: $(date -Is) ==="
echo "Counts:"
echo -n "  multicoil_train: "; find multicoil_train -name '*.h5' 2>/dev/null | wc -l
echo -n "  multicoil_val:   "; find multicoil_val -name '*.h5' 2>/dev/null | wc -l
echo -n "  multicoil_test:  "; find multicoil_test -name '*.h5' 2>/dev/null | wc -l
du -sh multicoil_train multicoil_val multicoil_test 2>/dev/null || true
