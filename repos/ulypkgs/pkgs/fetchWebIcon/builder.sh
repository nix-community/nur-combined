source "$NIX_ATTRS_SH_FILE"

runHook preFetch

downloadUrl=$(curl -sL "$url" | pup 'link[rel="icon"] attr{href}' | head -n 1)
curl -L "$downloadUrl" -o "$out"

runHook postFetch
