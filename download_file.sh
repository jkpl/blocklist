#!/usr/bin/env bash
set -euo pipefail

echo "Downloading $1 to $2" >&2
echo "# $1" > "$2"
curl -sSfL "$1" >> "$2"
