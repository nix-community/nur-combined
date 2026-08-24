{
  appimageTools,
  fetchurl,
  lib,
  nix-update-script,
}:
appimageTools.wrapType2 (finalAttrs: {
  pname = "sheepshaver-bin";
  version = "2026-08-11";
  src = fetchurl {
    url = "https://github.com/Korkman/macemu-appimage-builder/releases/download/${finalAttrs.version}/SheepShaver-x86_64.AppImage";
    sha256 = "sha256-Pq5rhTNSd1WYvIxJxKxv7FWDHlcPYezuRtzQotbEo0Q=";
  };

  extraPkgs =
    pkgs: with pkgs; [
      libthai
    ];

  extraInstallCommands = ''
    mv $out/bin/${finalAttrs.pname} $out/sheepshaver
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A MacOS run-time environment for BeOS and Linux that allows you to run classic MacOS applications inside the BeOS/Linux multitasking environment";
    homepage = "https://sheepshaver.cebix.net/";
    license = lib.licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sheepshaver";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
