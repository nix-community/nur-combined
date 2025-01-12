{
  pkgs,
  sources,
  utils,
  ...
}: let
  csound = pkgs.csound.overrideAttrs (_: {
    NIX_CFLAGS_COMPILE = ["-Wno-incompatible-pointer-types"];
  });
in
  pkgs.stdenv.mkDerivation {
    inherit (sources.tonez) pname version src;

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      unzip
    ];

    buildInputs = with pkgs;
      [
        csound
        stdenv.cc.cc.lib
      ]
      ++ utils.juce.commonBuildInputs;

    buildPhase = ''
      mkdir -p $out/lib/vst3
      cp -r ToneZ_V2.vst3 $out/lib/vst3
    '';

    meta = with pkgs.lib; {
      description = "Free cross-platform polyphonic synthesizer";
      homepage = "https://www.retornz.com/plugins/tonez";
      license = licenses.gpl3Only;
      platforms = ["x86_64-linux"];
      sourceProvenance = [sourceTypes.binaryNativeCode];
    };
  }
