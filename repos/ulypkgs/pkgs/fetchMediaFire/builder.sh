source "$NIX_ATTRS_SH_FILE"

runHook preFetch

downloadUrl=$(curl -sL "https://www.mediafire.com/file/$fileId" \
  | grep -o 'href="https://download.*\.mediafire\.com/[^"]*"' \
  | cut -d '"' -f 2)
curl -L "$downloadUrl" -o "$out"

runHook postFetch
