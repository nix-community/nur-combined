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
  commit = "6c44fff7549e941389a4ce072a95c5ff9db7237c";

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
appimageTools.wrapAppImage (finalAttrs: {
  pname = "rpcs3";
  version = "0.0.43-20415";

  src = fetchurl {
    url = "https://github.com/RPCS3/rpcs3-binaries-linux/releases/download/build-${commit}/rpcs3-v${finalAttrs.version}-${lib.substring 0 8 commit}_linux64.AppImage";
    hash = "sha256-+74QJRFHGyEVDqOqLLwVZi4KsmyryzRoB/b8ow/3pio=";
  };

  # A uruntime (DwarFS) AppImage, which appimageTools.extract can't unpack:
  # let it extract itself.
  contents = runCommand "${finalAttrs.pname}-${finalAttrs.version}-extracted" { } ''
    cp ${finalAttrs.src} rpcs3.AppImage
    chmod +x rpcs3.AppImage

    ./rpcs3.AppImage --appimage-extract
    mv AppDir "$out"
  '';

  # The bundled libgcrypt needs it; appimageTools stopped providing it.
  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  # RPCS3 vendors Qt; system plugin paths (e.g. from Plasma) mix
  # Qt versions and abort in createPlatformIntegration.
  profile = ''
    unset QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH
  '';

  extraInstallCommands = ''
    install -Dm444 \
      ${finalAttrs.contents}/usr/share/applications/rpcs3.desktop \
      $out/share/applications/rpcs3.desktop

    cp -r ${finalAttrs.contents}/usr/share/icons $out/share/

    install -Dm444 \
      ${finalAttrs.contents}/usr/share/metainfo/rpcs3.metainfo.xml \
      $out/share/metainfo/rpcs3.metainfo.xml
  '';

  passthru.updateScript = [
    (lib.getExe updateScript)
    "pkgs/rpcs3-bin/package.nix"
  ];

  meta = {
    description = "PlayStation 3 emulator and debugger";
    homepage = "https://rpcs3.net/";
    license = lib.licenses.gpl2Only;
    mainProgram = "rpcs3";
    platforms = [ "x86_64-linux" ];
  };
})
