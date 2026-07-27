{
  sources,

  appimageTools,
  lib,
}:
appimageTools.wrapType2 {
  inherit (sources.sheepshaver-bin) pname version src;

  extraPkgs =
    pkgs: with pkgs; [
      libthai
    ];

  extraInstallCommands = ''
    mv $out/bin/${sources.sheepshaver-bin.pname} $out/sheepshaver
  '';

  meta = {
    description = "A MacOS run-time environment for BeOS and Linux that allows you to run classic MacOS applications inside the BeOS/Linux multitasking environment";
    homepage = "https://sheepshaver.cebix.net/";
    license = lib.licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    mainProgram = "sheepshaver";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
