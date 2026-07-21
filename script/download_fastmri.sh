#!/usr/bin/env bash
# Download NYU fastMRI brain multicoil batch 0 only (train / val / test)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="${ROOT}/data"
ARCHIVES_DIR="${DATA_DIR}/archives"
mkdir -p "${ARCHIVES_DIR}" \
  "${DATA_DIR}/multicoil_train" \
  "${DATA_DIR}/multicoil_val" \
  "${DATA_DIR}/multicoil_test"
cd "${ARCHIVES_DIR}"

LOG="${DATA_DIR}/download.log"
exec > >(tee -a "${LOG}") 2>&1

echo "=== fastMRI download started: $(date -Is) ==="
echo "Archives directory: ${ARCHIVES_DIR}"
echo "Files: train_batch_0, val_batch_0, test_batch_0"

download() {
  local url="$1"
  local out="$2"
  echo ""
  echo ">>> Downloading ${out} ($(date -Is))"
  curl -L -C - --retry 10 --retry-delay 5 --retry-all-errors \
    "${url}" --output "${out}"
  echo "<<< Finished ${out} ($(date -Is))"
}

# Prefer resuming a partial archive left in data/ from an earlier run
if [[ -f "${DATA_DIR}/brain_multicoil_train_batch_0.tar.xz" && ! -f "${ARCHIVES_DIR}/brain_multicoil_train_batch_0.tar.xz" ]]; then
  mv "${DATA_DIR}/brain_multicoil_train_batch_0.tar.xz" "${ARCHIVES_DIR}/"
fi

download "https://fastmri-dataset.s3.amazonaws.com/v2.0/brain_multicoil_train_batch_0.tar.xz?AWSAccessKeyId=AKIAJM2LEZ67Y2JL3KRA&Signature=dXenTVUxZJnR6cHkoHPHa%2FQQASI%3D&Expires=1791786043" "brain_multicoil_train_batch_0.tar.xz"
download "https://fastmri-dataset.s3.amazonaws.com/v2.0/brain_multicoil_val_batch_0.tar.xz?AWSAccessKeyId=AKIAJM2LEZ67Y2JL3KRA&Signature=3PqbBkOk9mLAx6fFIN4bYbZ5Uuc%3D&Expires=1791786043" "brain_multicoil_val_batch_0.tar.xz"
download "https://fastmri-dataset.s3.amazonaws.com/v2.0/brain_multicoil_test_batch_0.tar.xz?AWSAccessKeyId=AKIAJM2LEZ67Y2JL3KRA&Signature=QqWCnWmxI4e3Ffh0kfLP2tNocI0%3D&Expires=1791786043" "brain_multicoil_test_batch_0.tar.xz"

echo ""
echo "=== fastMRI download finished: $(date -Is) ==="
echo "Extract later into:"
echo "  ${DATA_DIR}/multicoil_train"
echo "  ${DATA_DIR}/multicoil_val"
echo "  ${DATA_DIR}/multicoil_test"
ls -lh "${ARCHIVES_DIR}"/*.tar.* 2>/dev/null || true
