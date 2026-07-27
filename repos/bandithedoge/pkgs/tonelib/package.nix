{
  sources,

  lib,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  dpkg,
  freetype,
  gtk3,
  libGL,
  webkitgtk_4_1,
}:
let
  mkToneLib =
    name: meta:
    stdenv.mkDerivation {
      inherit (sources.${name}) pname version src;

      nativeBuildInputs = [
        autoPatchelfHook
        dpkg
      ];

      buildInputs = [
        alsa-lib
        freetype
        libGL
      ];

      unpackPhase = ''
        mkdir -p root
        dpkg-deb --fsys-tarfile $src | tar --extract --directory=root
      '';

      buildPhase = ''
        runHook preBuild

        cp -r root/usr $out

        runHook postBuild
      '';

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  bassdrive = mkToneLib "bassdrive" {
    description = "Full Power of the Legendary Drive Pedal for the Highest String Gauges";
    homepage = "https://tonelib.net/tl-bassdrive.html";
    mainProgram = "ToneLib-BassDrive";
  };

  easycomp = mkToneLib "easycomp" {
    description = "Powerful Compressor without any Complexity";
    homepage = "https://tonelib.net/plugins/tl-easycomp.html";
    mainProgram = "ToneLib-EasyComp";
  };

  noisereducer = mkToneLib "noisereducer" {
    description = "Powerful, yet simple two-unit rack effect on guard of your mix clarity";
    homepage = "https://tonelib.net/tl-noisereducer.html";
    mainProgram = "ToneLib-NoiseReducer";
  };

  tubewarmth = mkToneLib "tubewarmth" {
    description = "The Vibrancy and Warmth of the Tube along with the Digital Precision and Clarity";
    homepage = "https://tonelib.net/tl-tubewarmth.html";
    mainProgram = "ToneLib-TubeWarmth";
  };

  zoom =
    (mkToneLib "zoom" {
      description = "Best way to manage your Zoom processor";
      homepage = "https://tonelib.net/tonelib-zoom.html";
      knownVulnerabilities = [
        "libsoup2 is EOL"
      ];
      insecure = true; # https://github.com/NixOS/nixpkgs/issues/360897
    }).overrideAttrs
      (old: {
        buildInputs = old.buildInputs ++ [
          gtk3
          stdenv.cc.cc.lib
          webkitgtk_4_1
        ];
      });
}
