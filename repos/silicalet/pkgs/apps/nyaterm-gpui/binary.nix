{
  lib,
  appimageTools,
  dbus,
  fetchurl,
  gtk3,
  libayatana-appindicator,
  stdenv,
  vulkan-loader,
  wayland,
}:

let
  pname = "nyaterm-gpui";
  sources = {
    x86_64-linux = import ./sources/x86_64-linux.nix;
    aarch64-linux = import ./sources/aarch64-linux.nix;
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "nyaterm-gpui-bin is unsupported on ${stdenv.hostPlatform.system}");
  inherit (source) version;
  src = fetchurl {
    inherit (source) url hash;
  };
  runtimeLibraries = [
    dbus
    gtk3
    libayatana-appindicator
    vulkan-loader
    wayland
  ];
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _: runtimeLibraries;

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      desktopFile="$(find ${contents} -path '*/share/applications/*.desktop' -print -quit)"
      if [ -n "$desktopFile" ]; then
        install -Dm444 "$desktopFile" "$out/share/applications/nyaterm-gpui.desktop"
        sed -i \
          -e 's|^Exec=.*|Exec=nyaterm-gpui %U|' \
          "$out/share/applications/nyaterm-gpui.desktop"
      fi

      if [ -d ${contents}/usr/share/icons ]; then
        cp -r ${contents}/usr/share/icons "$out/share/"
      fi
    '';

  meta = {
    description = "GPUI preview of the NyaTerm remote terminal workspace";
    homepage = "https://github.com/nyakang/nyaterm";
    changelog = "https://github.com/nyakang/nyaterm/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "nyaterm-gpui";
    platforms = builtins.attrNames sources;
  };
}
