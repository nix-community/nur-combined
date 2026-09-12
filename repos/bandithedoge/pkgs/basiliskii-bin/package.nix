{
  appimageTools,
  fetchurl,
  lib,
  nix-update-script,
}:
appimageTools.wrapType2 (finalAttrs: {
  pname = "basiliskii-bin";
  version = "2026-09-11";
  src = fetchurl {
    url = "https://github.com/Korkman/macemu-appimage-builder/releases/download/${finalAttrs.version}/BasiliskII-x86_64.AppImage";
    sha256 = "sha256-kRfnbg8S8gWh28nMymi6vsXFGP+8kIN8bS5rDCH0lNA=";
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
