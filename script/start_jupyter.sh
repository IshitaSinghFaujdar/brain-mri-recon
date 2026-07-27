#!/usr/bin/env bash
# Activate project venv, register kernel, start Jupyter Lab, print URL for Cursor.
#
# Usage:
#   ./script/start_jupyter.sh
#   PORT=8889 ./script/start_jupyter.sh
#
# In Cursor:
#   Select Kernel → Select Another Kernel → Existing Jupyter Server
#   → paste the URL :http://127.0.0.1:8888/?token=brainmri-recon

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV="${ROOT}/.venv"
PORT="${PORT:-8888}"
HOST="${HOST:-127.0.0.1}"
# Fixed token so the URL is stable across restarts (change if you share this machine).
TOKEN="${JUPYTER_TOKEN:-brainmri-recon}"
URL_FILE="${ROOT}/.jupyter_server_url"
KERNEL_NAME="brain-mri-recon"
KERNEL_DISPLAY="Python (brain-mri-recon)"

if [[ ! -x "${VENV}/bin/python" ]]; then
  echo "Missing venv at ${VENV}. Run: uv sync" >&2
  exit 1
fi

# Prefer venv tools without requiring an interactive `source activate`.
export PATH="${VENV}/bin:${PATH}"
export VIRTUAL_ENV="${VENV}"

echo "=== brain-mri-recon Jupyter ==="
echo "venv:  ${VENV}"
echo "python: $(python -c 'import sys; print(sys.executable)')"

# Make this env selectable as a normal Jupyter/Cursor kernel too.
python -m ipykernel install --user \
  --name "${KERNEL_NAME}" \
  --display-name "${KERNEL_DISPLAY}" \
  >/dev/null
echo "kernel registered: ${KERNEL_DISPLAY}"

URL="http://${HOST}:${PORT}/lab?token=${TOKEN}"
# Cursor "Existing Jupyter Server" accepts either /lab?... or /?...
CURSOR_URL="http://${HOST}:${PORT}/?token=${TOKEN}"

printf '%s\n' "${CURSOR_URL}" > "${URL_FILE}"
echo "${URL}" >> "${URL_FILE}"

copy_url() {
  local text="$1"
  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "${text}" | wl-copy && return 0
  fi
  if command -v xclip >/dev/null 2>&1; then
    printf '%s' "${text}" | xclip -selection clipboard && return 0
  fi
  if command -v xsel >/dev/null 2>&1; then
    printf '%s' "${text}" | xsel --clipboard --input && return 0
  fi
  return 1
}

echo
echo "------------------------------------------------------------"
echo " Paste THIS into Cursor → Select Kernel → Existing Jupyter Server:"
echo
echo "   ${CURSOR_URL}"
echo
echo " Also saved to: ${URL_FILE}"
echo "------------------------------------------------------------"
if copy_url "${CURSOR_URL}"; then
  echo "Copied URL to clipboard."
else
  echo "Clipboard tool not found — copy the URL above manually."
fi
echo
echo "Starting Jupyter Lab on ${HOST}:${PORT} (Ctrl+C to stop)..."
echo

cd "${ROOT}"
exec jupyter lab \
  --no-browser \
  --ip="${HOST}" \
  --port="${PORT}" \
  --ServerApp.token="${TOKEN}" \
  --ServerApp.password="" \
  --ServerApp.open_browser=False \
  --notebook-dir="${ROOT}"
