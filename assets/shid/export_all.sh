#!/usr/bin/env bash
# Exports every .blend in this directory to a .glb next to it.
set -euo pipefail

cd "$(dirname "$0")"

BLENDER="${BLENDER:-blender}"
failed=0

for blend in *.blend; do
    [ -e "$blend" ] || continue
    echo "==> $blend"
    if ! "$BLENDER" --background --factory-startup "$blend" --python export_glb.py; then
        echo "FAILED: $blend" >&2
        failed=1
    fi
done

exit "$failed"
