{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  dpkg,
  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.wavetable-bin) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{clap,lv2,vst3,vst}
    cp -r usr/lib/clap/Wavetable.clap $out/lib/clap
    cp -r usr/lib/lv2/Wavetable.lv2 $out/lib/lv2
    cp -r usr/lib/vst3/Wavetable.vst3 $out/lib/vst3
    cp usr/lib/vst/Wavetable.so $out/lib/vst

    runHook postBuild
  '';

  meta = {
    description = "Wavetable synth";
    homepage = "https://socalabs.com/synths/wavetable/";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
