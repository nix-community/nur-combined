{
  pkgs,
  sources,
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.lv2vst) src pname;
  version = sources.lv2vst.date;

  makeFlags = ["PREFIX=$(out)"];

  meta = with pkgs.lib; {
    description = "experimental LV2 to VST2.x wrapper";
    homepage = "https://github.com/x42/lv2vst";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
