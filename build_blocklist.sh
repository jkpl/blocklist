#!/usr/bin/env bash
set -euo pipefail

SOURCES_URL="https://v.firebog.net/hosts/lists.php?type=tick"
TARGET_DIR="$(mktemp -d tmp.XXXXX)"
SOURCES_FILE="${TARGET_DIR}/sources.txt"
FINAL_BLOCKLIST="blocklist.txt"
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

delete_target_dir() {
    if [ -d "${TARGET_DIR}" ] && [ -z "${DEBUG:-}" ]; then
        rm -r "${TARGET_DIR}"
    fi
}
trap delete_target_dir EXIT

mkdir -p \
    "${TARGET_DIR}/raw" \
    "${TARGET_DIR}/cleaned"

if [ ! -f "${SOURCES_FILE}" ]; then
    echo "Fetching source list" >&2
    "${CURDIR}/download_file.sh" "${SOURCES_URL}" "${SOURCES_FILE}"
fi

echo "Fetching blocklists" >&2
parallel "${CURDIR}/download_file.sh" {} "${TARGET_DIR}/raw/{#}.txt" < "${SOURCES_FILE}"

echo "Cleaning up blocklists" >&2
parallel "${CURDIR}/blocklist_cleanup.py" {} "${TARGET_DIR}/cleaned/{/}.txt" ::: "${TARGET_DIR}/raw"/*.txt

echo "Aggregating blocklists" >&2
sort --unique "${TARGET_DIR}/cleaned"/*.txt > "${FINAL_BLOCKLIST}"

cat <<EOF >&2
Stats:
  Sources crawled : $(wc -l < "${SOURCES_FILE}")
  Hosts blocked   : $(wc -l < "${FINAL_BLOCKLIST}")
EOF

