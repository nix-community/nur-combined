{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "audible-planets-bin";
  inherit (sources.audible-planets-lv2) version;
  srcs = with sources; [
    audible-planets-lv2.src
    audible-planets-vst3.src
  ];
  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = with pkgs;
    [
      stdenv.cc.cc.lib
    ]
    ++ utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/lib/{lv2,vst3}
    cp -r "Audible Planets.lv2" $out/lib/lv2
    cp -r "Audible Planets.vst3" $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "An expressive, quasi-Ptolemaic semi-modular synthesizer";
    homepage = "https://github.com/gregrecco67/AudiblePlanets";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
