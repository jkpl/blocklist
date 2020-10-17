#!/usr/bin/env bash
set -euo pipefail

echo "Downloading $1 to $2" >&2
curl -sSfL -o "$2" "$1" >/dev/null
