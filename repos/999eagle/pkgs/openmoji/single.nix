{
  writeShellScript,
  openmoji,
  stdenv,
}: format: let
  supportedFormats = [
    "cbdt"
    "glyf_colr_0"
    "glyf_colr_1"
    "colr0_svg"
    "colr1_svg"
    "cbdt_colr0_svg"
    "cbdt_colr1_svg"
  ];
in
  assert builtins.elem format supportedFormats;
    stdenv.mkDerivation {
      inherit format;
      name = "openmoji-${format}";
      src = openmoji;
      installPhase = ''
        runHook preBuild

        mkdir -p $out/share/fonts/truetype
        cp share/fonts/truetype/OpenMoji-color-$format.ttf $out/share/fonts/truetype

        runHook postBuild
      '';
    }
