{
  appimageTools,
  fetchurl,
  lib,
  nix-update-script,
}:
appimageTools.wrapType2 (finalAttrs: {
  pname = "basiliskii-bin";
  version = "2026-08-11";
  src = fetchurl {
    url = "https://github.com/Korkman/macemu-appimage-builder/releases/download/${finalAttrs.version}/BasiliskII-x86_64.AppImage";
    sha256 = "sha256-TkQX1BppFTX3FAOqBFSgqLGMlJn9fb5Wwub9Z6fTcbs=";
  };

  extraPkgs =
    pkgs: with pkgs; [
      libthai
    ];

  extraInstallCommands = ''
    mv $out/bin/${finalAttrs.pname} $out/bin/basiliskii
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "68k Macintosh emulator";
    homepage = "https://basilisk.cebix.net/";
    license = lib.licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    mainProgram = "basiliskii";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
