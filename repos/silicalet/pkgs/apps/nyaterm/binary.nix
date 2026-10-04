{
  lib,
  appimageTools,
  fetchurl,
  fontconfig,
  freetype,
  glib-networking,
  libayatana-appindicator,
  openssl,
  stdenv,
  udev,
  webkitgtk_4_1,
}:

let
  pname = "nyaterm";
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "nyaterm-bin is unsupported on ${stdenv.hostPlatform.system}");
  inherit (source) version;
  src = fetchurl {
    inherit (source) url hash;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

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

  meta = {
    description = "Modern remote terminal workspace with SSH, SFTP and AI assistance";
    homepage = "https://github.com/nyakang/nyaterm";
    changelog = "https://github.com/nyakang/nyaterm/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "nyaterm";
    platforms = builtins.attrNames sources;
  };
}
