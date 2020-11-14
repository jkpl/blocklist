#!/usr/bin/env bash
# This script is used for finding which list blocks what
set -euo pipefail

TARGET_DIR="${1}"
QUERY="${2}"

main() {
    local source_url
    local content
    for blockfile in "${TARGET_DIR}"/*.txt; do
        source_url=$(head -n 1 "${blockfile}" | awk '{print $2}')
        content=$(grep "${QUERY}" "${blockfile}" || true)
        if [ -n "${content:-}" ]; then
            echo "${source_url}"
            # shellcheck disable=SC2001
            echo "${content}" | sed 's/^/  - /'
        fi
    done
}

main