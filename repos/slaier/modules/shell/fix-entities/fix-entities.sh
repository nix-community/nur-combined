#!/usr/bin/env bash
set -euo pipefail
dir="${1:-.}"
langmap() {
  case "${2,,}" in
    *traditional*|*zh-hant*|*zht*) echo "zh-Hant" ;;
    *simplified*|*zh-hans*|*zhs*) echo "zh-Hans" ;;
    *eng*) echo "en" ;;
    *jap*|*jpn*) echo "ja" ;;
    *chi*|*zho*) echo "zh" ;;
    *) echo "${2:-und}" ;;
  esac
}
command -v mkvextract >/dev/null || { echo "need mkvtoolnix: nix shell nixpkgs#mkvtoolnix"; exit 1; }
for f in "$dir"/*.mkv; do
  b="${f%.mkv}"
  mkvmerge -J "$f" | python3 -c '
import json,sys
d=json.load(sys.stdin)
for t in d["tracks"]:
    if t["type"]=="subtitles" and t["codec"]=="SubRip/SRT":
        p=t["properties"]
        print(t["id"], p.get("track_name") or p.get("language") or "und")
' | while read -r id name; do
    lang=$(langmap x "$name")
    out="$b.$lang.srt"
    [ -e "$out" ] && out="$b.$lang-$id.srt"
    mkvextract tracks "$f" "$id:$out" >/dev/null
    if grep -q "&[a-z#0-9]*;" "$out"; then
      sed -i 's/&[a-z]*;//g; s/&#x\?[0-9a-fA-F]*;//g' "$out"
      echo "fixed: $out"
    else
      rm "$out"
    fi
  done
done
