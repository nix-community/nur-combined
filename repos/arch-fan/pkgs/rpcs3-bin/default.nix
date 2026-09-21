{
  lib,
  appimageTools,
  fetchurl,
  runCommand,
  writeShellApplication,
  curl,
  jq,
  nix,
  perl,
}:

let
  pname = "rpcs3";
  version = "0.0.42-20031";

  commit = "d08d568d5edf4f21508d9b8e471197e6d6f499ad";
  shortCommit = "d08d568d";

  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-${commit}/rpcs3-v${version}-${shortCommit}_linux64.AppImage";
    hash = "sha256-n8++qddIuBLdcohsbhBdPtNB2/w8FXdalvM+oZaicjU=";
  };

  contents = runCommand "${pname}-${version}-extracted" { } ''
    cp ${src} rpcs3.AppImage
    chmod +x rpcs3.AppImage

    ./rpcs3.AppImage --appimage-extract
    mv AppDir "$out"
  '';

  updateScript = writeShellApplication {
    name = "update-rpcs3-bin";

    runtimeInputs = [
      curl
      jq
      nix
      perl
    ];

    text = builtins.readFile ./update.sh;
  };
in
appimageTools.wrapAppImage {
  inherit pname version contents;

  # RPCS3 vendors Qt; system plugin paths (e.g. from Plasma) mix
  # Qt versions and abort in createPlatformIntegration.
  profile = ''
    unset QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH
  '';

  extraInstallCommands = ''
    install -Dm444 \
      ${contents}/usr/share/applications/rpcs3.desktop \
      $out/share/applications/rpcs3.desktop

    cp -r \
      ${contents}/usr/share/icons \
      $out/share/

    install -Dm444 \
      ${contents}/usr/share/metainfo/rpcs3.metainfo.xml \
      $out/share/metainfo/rpcs3.metainfo.xml
  '';

  passthru.updateScript = [
    (lib.getExe updateScript)
    "pkgs/rpcs3-bin/default.nix"
  ];

  meta = {
    description = "PlayStation 3 emulator and debugger";
    homepage = "https://rpcs3.net/";
    license = lib.licenses.gpl2Only;
    mainProgram = "rpcs3";
    platforms = [ "x86_64-linux" ];
  };
}
