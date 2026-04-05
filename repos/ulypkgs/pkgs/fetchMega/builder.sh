source "$NIX_ATTRS_SH_FILE"

runHook preFetch

if [[ -n "$NIX_MEGA_EMAIL" && -n "$NIX_MEGA_PASSWORD" ]]; then
  mega-login "$NIX_MEGA_EMAIL" "$NIX_MEGA_PASSWORD"
fi

megaExtraFlags=()
if [[ -n "$password" ]]; then
  megaExtraFlags+=(--password "$password")
fi
mega-get "${megaExtraFlags[@]}" "https://mega.nz/#$fileId" "$out"

runHook postFetch
