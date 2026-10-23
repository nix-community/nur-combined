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
  version = "0.0.43-20375";

  commit = "0dec46b12e856756ba04271207a99a1de2208720";
  shortCommit = "0dec46b1";

  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-${commit}/rpcs3-v${version}-${shortCommit}_linux64.AppImage";
    hash = "sha256-Q60o9LY9C0olIbi2r+arEtycy7cv/YmvB0v2ENiSI+4=";
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
