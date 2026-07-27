{
  sources,

  lib,
  stdenv,
}:
stdenv.mkDerivation {
  inherit (sources.lv2vst) src pname;
  version = sources.lv2vst.date;

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "experimental LV2 to VST2.x wrapper";
    homepage = "https://github.com/x42/lv2vst";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
