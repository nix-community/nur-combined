{
  lib,
  copyDesktopItems,
  dxvk,
  fetchurl,
  icoutils,
  makeDesktopItem,
  runtimeShell,
  stdenvNoCC,
  unzip,
  wineWow64Packages,
  writeScript,
}:

let
  wine = wineWow64Packages.staging;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "paintdotnet";
  version = "5.200.9771.42255";

  src = fetchurl {
    url = "https://github.com/paintdotnet/Paint.NET-on-Wine/releases/download/v${finalAttrs.version}/paint.net.${finalAttrs.version}.portable.x64.wine.EXPERIMENTAL.zip";
    hash = "sha256-Qlf3K7+wssSc2XM0tPV0sM/+cXnCzh2bgO9UZewihP4=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "paintdotnet";
      desktopName = "Paint.NET";
      comment = finalAttrs.meta.description;
      exec = "paintdotnet %F";
      icon = "paintdotnet";
      categories = [
        "Graphics"
        "2DGraphics"
        "RasterGraphics"
      ];
      startupWMClass = "paintdotnet.exe";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    icoutils
    unzip
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/paintdotnet $out/share/icons/hicolor/256x256/apps
    cp -r . $out/share/paintdotnet
    icotool \
      --extract \
      --index=5 \
      --output=$out/share/icons/hicolor/256x256/apps/paintdotnet.png \
      paintdotnet.ico

    cat <<'EOF' > $out/bin/paintdotnet
    #!${runtimeShell}
    set -euo pipefail

    export PATH=${wine}/bin:$PATH
    export PAINTDOTNET_HOME="''${PAINTDOTNET_HOME:-"''${XDG_DATA_HOME:-"''${HOME}/.local/share"}/paintdotnet"}"
    export WINEARCH=win64
    export WINEPREFIX="$PAINTDOTNET_HOME/wine"
    export WINEDEBUG="''${WINEDEBUG:--all}"
    export DXVK_LOG_LEVEL="''${DXVK_LOG_LEVEL:-error}"
    export WINEDLLOVERRIDES="mshtml="

    app_dir="$PAINTDOTNET_HOME/app"
    if [ ! -e "$app_dir/.paintdotnet-${finalAttrs.version}-installed" ]; then
      mkdir -p "$app_dir"
      cp -r ${placeholder "out"}/share/paintdotnet/. "$app_dir/"
      chmod -R u+w "$app_dir"
      touch "$app_dir/.paintdotnet-${finalAttrs.version}-installed"
    fi

    if [ ! -e "$WINEPREFIX/.paintdotnet-initialized" ]; then
      mkdir -p "$WINEPREFIX"
      WINEDLLOVERRIDES="mscoree,mshtml=" wineboot --init
      wineserver -w
      winecfg -v win11
      touch "$WINEPREFIX/.paintdotnet-initialized"
    fi

    if [ ! -e "$WINEPREFIX/.paintdotnet-dxvk-x64-installed" ]; then
      system32="$WINEPREFIX/drive_c/windows/system32"
      for dll in d3d10core d3d11 dxgi; do
        if [ ! -e "$system32/$dll.dll.old" ]; then
          mv "$system32/$dll.dll" "$system32/$dll.dll.old"
        fi
        install -m755 ${dxvk.dxvk64}/bin/$dll.dll "$system32/$dll.dll"
        wine reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' \
          /v "$dll" /d native /f >/dev/null
      done
      wineserver -w
      touch "$WINEPREFIX/.paintdotnet-dxvk-x64-installed"
    fi

    export WINEDLLOVERRIDES="mshtml=;d3dcompiler_47=n"
    cd "$app_dir"
    exec wine ./paintdotnet.exe "$@"
    EOF
    chmod +x $out/bin/paintdotnet

    runHook postInstall
  '';

  passthru.updateScript = writeScript "update-paintdotnet" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    set -euo pipefail
    repo="https://api.github.com/repos/paintdotnet/Paint.NET-on-Wine/releases"
    version="$(curl --fail --silent --show-error --location "$repo" | jq --exit-status --raw-output '
      [.[] | select(.prerelease == false and (.tag_name | test("^v[0-9]+(\\.[0-9]+)+$")))]
      | .[0].tag_name | strings | sub("^v"; "") | select(length > 0)
    ')"
    update-source-version paintdotnet "$version"
  '';

  meta = {
    description = "Experimental Paint.NET build for Wine";
    homepage = "https://github.com/paintdotnet/Paint.NET-on-Wine";
    downloadPage = "https://github.com/paintdotnet/Paint.NET-on-Wine/releases";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "paintdotnet";
    platforms = [ "x86_64-linux" ];
  };
})
