{
  sources,

  appimageTools,
  lib,
}:
appimageTools.wrapType2 {
  inherit (sources.basiliskii-bin) pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      libthai
    ];

  extraInstallCommands = ''
    mv $out/bin/${sources.basiliskii-bin.pname} $out/bin/basiliskii
  '';

  meta = {
    description = "68k Macintosh emulator";
    homepage = "https://basilisk.cebix.net/";
    license = lib.licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    mainProgram = "basiliskii";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
