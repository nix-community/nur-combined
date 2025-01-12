{
  pkgs,
  sources,
  utils,
  ...
}: let
  mkWea = {
    name,
    source,
    description,
    homepage,
    license ? pkgs.lib.licenses.gpl3,
  }:
    pkgs.stdenv.mkDerivation rec {
      inherit (source) pname version src;

      sourceRoot = "${name} v${version}";

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
        ls
        mkdir -p $out/lib/vst3

        cp -r Linux/${name}.vst3 $out/lib/vst3
      '';

      meta = with pkgs.lib; {
        inherit description homepage license;
        platforms = ["x86_64-linux"];
        sourceProvenance = [sourceTypes.binaryNativeCode];
      };
    };
in {
  songbird-bin = mkWea {
    name = "Songbird";
    source = sources.songbird-bin;
    description = "Songbird adds subtle textures or expressive vowel sounds to any instrument using a pair of formant filter banks and the built in modulation options";
    homepage = "https://whiteelephantaudio.com/plugins/songbird";
  };

  richter-bin = mkWea {
    name = "Richter";
    source = sources.richter-bin;
    description = "Richter is an experimental tremolo/amplitude modulation tool with a pair of LFOs to modulate the audio directly, each with its own additional modulation LFO";
    homepage = "https://whiteelephantaudio.com/plugins/richter";
  };

  monstr-bin = mkWea {
    name = "MONSTR";
    source = sources.monstr-bin;
    description = "MONSTR provides up to six bands of stereo width control to correct mix issues or use for creative effect";
    homepage = "https://whiteelephantaudio.com/plugins/monstr";
  };

  carve-bin = mkWea {
    name = "Carve";
    source = sources.carve-bin;
    description = "Carve is an experimental wave shaping distortion, with a pair of distortions, flexible routing, and multiple algorithms to choose from";
    homepage = "https://whiteelephantaudio.com/plugins/carve";
  };
}
