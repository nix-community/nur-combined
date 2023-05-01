{
  sources,
  pkgs,
}:
pkgs.appimageTools.wrapType2 {
  name = "SheepShaver";
  inherit (sources.sheepshaver-bin) src;

  extraPkgs = pkgs:
    with pkgs; [
      libthai
    ];

  meta = with pkgs.lib; {
    description = "A MacOS run-time environment for BeOS and Linux that allows you to run classic MacOS applications inside the BeOS/Linux multitasking environment";
    homepage = "https://sheepshaver.cebix.net/";
    license = licenses.gpl2;
    platforms = ["x86_64-linux"];
  };
}
