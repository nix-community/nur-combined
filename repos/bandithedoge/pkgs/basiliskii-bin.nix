{
  sources,
  pkgs,
}:
pkgs.appimageTools.wrapType2 {
  name = "BasiliskII";
  inherit (sources.basiliskii-bin) src;

  extraPkgs = pkgs:
    with pkgs; [
      libthai
    ];

  meta = with pkgs.lib; {
    description = "68k Macintosh emulator";
    homepage = "https://basilisk.cebix.net/";
    license = licenses.gpl2;
    platforms = ["x86_64-linux"];
  };
}
