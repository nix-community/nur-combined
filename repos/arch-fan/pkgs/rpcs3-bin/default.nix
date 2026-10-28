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
  version = "0.0.43-20412";

  commit = "744126caff4daf91d31ae81fc5ab19ff65f87b32";
  shortCommit = "744126ca";

  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-${commit}/rpcs3-v${version}-${shortCommit}_linux64.AppImage";
    hash = "sha256-2S/KfQYWZvoPhPpqyX9xRQj6a52+U7xrNF+sX/aben8=";
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
