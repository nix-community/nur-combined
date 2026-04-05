source "$NIX_ATTRS_SH_FILE"

runHook preFetch

if [[ -n "$NIX_GDOWN_COOKIES" ]]; then
  export HOME="$(mktemp -d)"
  mkdir -p "$HOME/.config/gdown"
  echo "$NIX_GDOWN_COOKIES" > "$HOME/.config/gdown/cookies.txt"
  cat ~/.config/gdown/cookies.txt
else
  extraGdownArgs+=(--no-cookies)
fi

if [[ -n "$fileId" ]]; then
  gdown "$fileId" --output "$out" ${extraGdownArgs[@]}
else
  gdown "$folderId" --folder --output "$out" ${extraGdownArgs[@]}
fi

runHook postFetch
