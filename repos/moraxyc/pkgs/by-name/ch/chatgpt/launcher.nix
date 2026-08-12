# Electron rewrites bundled plugin manifests, so they need a writable copy.
{ writeShellApplication }:

writeShellApplication {
  name = "chatgpt-launcher";

  text = ''
    : "''${CHATGPT_EXECUTABLE:?}"
    : "''${CHATGPT_RESOURCES_SOURCE:?}"
    : "''${CHATGPT_RESOURCES_CACHE_KEY:?}"

    cacheHome="''${XDG_CACHE_HOME:-''${HOME:?XDG_CACHE_HOME and HOME are unset}/.cache}"
    cacheRoot="$cacheHome/chatgpt/bundled-plugins"
    resourcesPath="$cacheRoot/$CHATGPT_RESOURCES_CACHE_KEY"

    if [[ ! -f "$resourcesPath/.complete" ]]; then
      mkdir -p "$cacheRoot"
      stagingPath=$(mktemp -d "$cacheRoot/.staging-$CHATGPT_RESOURCES_CACHE_KEY.XXXXXXXX")
      trap 'rm -rf -- "$stagingPath"' EXIT

      ln -s \
        "$CHATGPT_RESOURCES_SOURCE/"{codex,codex-code-mode-host,cua_node,native,rg} \
        "$stagingPath"
      cp -R "$CHATGPT_RESOURCES_SOURCE/plugins" "$stagingPath/plugins"
      chmod -R u+w "$stagingPath/plugins"
      touch "$stagingPath/.complete"

      if mv -T "$stagingPath" "$resourcesPath" 2>/dev/null; then
        trap - EXIT
      elif [[ -f "$resourcesPath/.complete" ]]; then
        rm -rf -- "$stagingPath"
        trap - EXIT
      else
        echo "Failed to publish ChatGPT's writable bundled-plugin resources" >&2
        exit 1
      fi
    fi

    export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$resourcesPath"

    waylandFlags=()
    if [[ -n "''${NIXOS_OZONE_WL:-}" && -n "''${WAYLAND_DISPLAY:-}" ]]; then
      waylandFlags=(
        --ozone-platform-hint=auto
        --enable-features=WaylandWindowDecorations
        --enable-wayland-ime=true
      )
    fi

    exec "$CHATGPT_EXECUTABLE" "''${waylandFlags[@]}" "$@"
  '';
}
