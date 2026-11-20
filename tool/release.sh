#!/usr/bin/env bash
# tool/release.sh <id> <dir>   — publish the files of model <id> from <dir> as release <release>
# tool/release.sh catalog      — (re)publish catalog.json as the `catalog` release
set -euo pipefail
cd "$(dirname "$0")/.."
REPO=eq-devs/qazvoice-models
if [ "${1:-}" = catalog ]; then
  gh release view catalog -R $REPO >/dev/null 2>&1 || \
    gh release create catalog -R $REPO --title "Model catalog" --notes "catalog.json read by the qazvoice plugin. Updated whenever a model release is added." --latest=false
  # The plugin only trusts a catalog signed with its built-in Ed25519 key.
  openssl pkeyutl -sign -inkey "${CATALOG_KEY:-$HOME/Desktop/eq/qazstt/signing/qazvoice-catalog-ed25519.pem}" \
    -rawin -in catalog.json | xxd -p -c 256 | tr -d '\n' > catalog.json.sig
  gh release upload catalog catalog.json catalog.json.sig -R $REPO --clobber
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
    if "zst" in f:
        z = p + ".zst"
        if not os.path.exists(z):
            sys.exit(f"{f['name']}: catalog lists a .zst copy; create it with `zstd -19 {p}`")
        zh = hashlib.sha256(open(z, "rb").read()).hexdigest()
        if os.path.getsize(z) != f["zst"]["size"] or zh != f["zst"]["sha256"]:
            sys.exit(f"{f['name']}.zst: catalog and file differ")
        os.symlink(os.path.realpath(z), os.path.join(stage, f["name"] + ".zst"))
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
