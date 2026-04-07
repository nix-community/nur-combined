source "$NIX_ATTRS_SH_FILE"

runHook preFetch

megaLoggedIn=""
if [[ -n "$NIX_MEGA_EMAIL" && -n "$NIX_MEGA_PASSWORD" ]]; then
  mega-login "$NIX_MEGA_EMAIL" "$NIX_MEGA_PASSWORD"
  megaLoggedIn=1
fi

megaPasswordFlags=()
if [[ -n "$password" ]]; then
  megaPasswordFlags+=(--password "$password")
fi

if [[ -n "$fileId" ]]; then
  mega-get "${megaPasswordFlags[@]}" "https://mega.nz/#$fileId" "$out"
elif [[ -z "$pathInFolder" ]]; then
  mega-get "${megaPasswordFlags[@]}" "https://mega.nz/folder/$folderId" "$out"
elif [[ -n "$megaLoggedIn" ]]; then
  # mega is such a pain! why cannot i just download a file in a folder???
  if ! mega-ls NIX_fetchMega; then
    mega-mkdir -p NIX_fetchMega
  fi
  importedPath="$(mega-import "${megaPasswordFlags[@]}" "https://mega.nz/folder/$folderId" NIX_fetchMega | grep -oP 'Imported folder complete: \K.*')"
  mega-get "$importedPath/$pathInFolder" "$out"
  mega-rm -r -f "$importedPath"
else
  mega-login "${megaPasswordFlags[@]}" "https://mega.nz/folder/$folderId"
  mega-get "$pathInFolder" "$out"
fi

runHook postFetch
