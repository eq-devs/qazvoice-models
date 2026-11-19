#!/usr/bin/env bash
# tool/release.sh <id> <dir>   — publish the files of model <id> from <dir> as release <release>
# tool/release.sh catalog      — (re)publish catalog.json as the `catalog` release
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=eq-devs/qazvoice-models
if [ "${1:-}" = catalog ]; then
  gh release view catalog -R $REPO >/dev/null 2>&1 || \
    gh release create catalog -R $REPO --title "Model catalog" --notes "catalog.json read by the qazvoice plugin. Updated whenever a model release is added." --latest=false
  gh release upload catalog catalog.json -R $REPO --clobber
  exit 0
fi
ID=$1; SRC=$2
REL=$(python3 -c "import json,sys;print(json.load(open('catalog.json'))['models'][sys.argv[1]]['release'])" "$ID")
LIC=$(python3 -c "import json,sys;print(json.load(open('catalog.json'))['models'][sys.argv[1]]['license'])" "$ID")
STAGE=$(mktemp -d)
python3 - "$ID" "$SRC" "$STAGE" <<'PY'
import hashlib, json, os, shutil, sys
mid, src, stage = sys.argv[1:4]
m = json.load(open("catalog.json"))["models"][mid]
for f in m["files"]:
    p = os.path.join(src, f["name"])
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for b in iter(lambda: fh.read(1 << 20), b""):
            h.update(b)
    size = os.path.getsize(p)
    if size != f["size"] or h.hexdigest() != f["sha256"]:
        sys.exit(f"{f['name']}: catalog says {f['size']} {f['sha256']}, file is {size} {h.hexdigest()}")
    os.symlink(os.path.realpath(p), os.path.join(stage, f["name"]))
PY
case "$LIC" in
  CC-BY-4.0*) cp licenses/CC-BY-4.0.txt "$STAGE/LICENSE" ;;
  Apache-2.0) cp licenses/Apache-2.0.txt "$STAGE/LICENSE" ;;
esac
case "$LIC" in *MIT*) cp licenses/MIT-silero-vad.txt "$STAGE/LICENSE-silero-vad" ;; esac
cp "attribution/$ID.md" "$STAGE/ATTRIBUTION.md"
NOTES="$(cat "attribution/$ID.md")"
gh release view "$REL" -R $REPO >/dev/null 2>&1 || gh release create "$REL" -R $REPO --title "$REL" --notes "$NOTES" --latest=false
gh release upload "$REL" -R $REPO --clobber "$STAGE"/*
echo "published $REL"
