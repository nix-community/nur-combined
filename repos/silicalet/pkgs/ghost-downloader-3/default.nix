{
  lib,
  appimageTools,
  fetchurl,
  libxcb-cursor,
  nix-update-script,
  zstd,
}:

appimageTools.wrapType2 rec {
  pname = "ghost-downloader-3";
  version = "4.2.0";

  src = fetchurl {
    url = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/download/v${version}/Ghost-Downloader-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-r0gAEU3tVx36lZ8eeYFFA3CD0JKhL/c6lPTnTmTgObg=";
  };

  extraPkgs = _: [
    libxcb-cursor
    zstd
  ];

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      desktopFile="$(find ${contents} -path '*/share/applications/*.desktop' -print -quit)"
      if [ -n "$desktopFile" ]; then
        install -Dm444 "$desktopFile" "$out/share/applications/ghost-downloader-3.desktop"
        sed -i \
          -e 's|^Exec=.*|Exec=ghost-downloader-3 %U|' \
          "$out/share/applications/ghost-downloader-3.desktop"
      fi

      if [ -d ${contents}/usr/share/icons ]; then
        cp -r ${contents}/usr/share/icons "$out/share/"
      fi
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform multi-protocol concurrent downloader";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    changelog = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "ghost-downloader-3";
    platforms = [ "x86_64-linux" ];
  };
}
