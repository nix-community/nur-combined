{
  lib,
  appimageTools,
  fetchurl,
  fontconfig,
  freetype,
  glib-networking,
  libayatana-appindicator,
  nix-update-script,
  openssl,
  udev,
  webkitgtk_4_1,
}:

appimageTools.wrapType2 rec {
  pname = "nyaterm";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/nyakang/nyaterm/releases/download/v${version}/NyaTerm_${version}_linux_x64.AppImage";
    hash = "sha256-YmDVmVlaPvWiHTP16rmSYFrcjmqvlcHImeyTsZH7qnI=";
  };

  extraPkgs = _: [
    fontconfig
    freetype
    glib-networking
    libayatana-appindicator
    openssl
    udev
    webkitgtk_4_1
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
        install -Dm444 "$desktopFile" "$out/share/applications/nyaterm.desktop"
        sed -i \
          -e 's|^Exec=.*|Exec=nyaterm %U|' \
          "$out/share/applications/nyaterm.desktop"
      fi

      if [ -d ${contents}/usr/share/icons ]; then
        cp -r ${contents}/usr/share/icons "$out/share/"
      fi
    '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "Modern remote terminal workspace with SSH, SFTP and AI assistance";
    homepage = "https://github.com/nyakang/nyaterm";
    changelog = "https://github.com/nyakang/nyaterm/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "nyaterm";
    platforms = [ "x86_64-linux" ];
  };
}
