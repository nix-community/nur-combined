{
  pkgs,
  sources,
  utils,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.just-a-sample-bin) pname version src;
  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
  ];

  buildInputs = utils.juce.commonBuildInputs;

  buildPhase = ''
    mkdir -p $out/lib/vst3
    cp -r JustASample.vst3 $out/lib/vst3
  '';

  meta = with pkgs.lib; {
    description = "Just a Sample is a modern, open-source audio sampler";
    homepage = "https://bobona.github.io/just-a-sample/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
