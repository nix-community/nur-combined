{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
stdenv.mkDerivation {
  pname = "audible-planets-bin";
  inherit (sources.audible-planets-lv2) version;
  srcs = with sources; [
    audible-planets-lv2.src
    audible-planets-vst3.src
  ];
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ]
  ++ juceCmakeHook.commonBuildInputs;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/lib/{lv2,vst3}
    cp -r "Audible Planets.lv2" $out/lib/lv2
    cp -r "Audible Planets.vst3" $out/lib/vst3

    runHook postBuild
  '';

  meta = {
    description = "An expressive, quasi-Ptolemaic semi-modular synthesizer";
    homepage = "https://github.com/gregrecco67/AudiblePlanets";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
