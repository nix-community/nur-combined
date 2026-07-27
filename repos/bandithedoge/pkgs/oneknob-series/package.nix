{
  sources,

  lib,
  stdenv,

  pkg-config,
}:
stdenv.mkDerivation {
  inherit (sources.oneknob-series) pname src;
  version = sources.oneknob-series.date;

  nativeBuildInputs = [
    pkg-config
  ];

  postPatch = ''
    patchShebangs .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/{clap,lv2,vst3,vst,ladspa}
    cp bin/*.clap $out/lib/clap
    cp -r bin/*.lv2 $out/lib/lv2
    cp -r bin/*.vst3 $out/lib/vst3
    cp bin/*-vst.so $out/lib/vst
    cp bin/*-ladspa.so $out/lib/ladspa

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Collection of stupidly simple but well-polished and visually pleasing audio plugins";
    homepage = "https://github.com/DISTRHO/OneKnob-Series";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
