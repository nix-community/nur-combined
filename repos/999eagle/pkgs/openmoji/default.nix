{
  stdenv,
  fetchFromGitHub,
  nanoemoji,
  gettext,
  runCommand,
  #fontFormats ? ["cbdt" "glyf_colr_0" "glyf_colr_1" "sbix" "picosvgz" "untouchedsvgz"],
  fontFormats ? ["glyf_colr_0"],
}: let
  buildToml = method: let
    saturation = "color";
  in
    runCommand "OpenMoji-${saturation}-${method}.toml" {
      inherit method saturation;
      toml = ./build.toml;
    } ''
      ${gettext}/bin/envsubst '$method $saturation' < $toml > $out
    '';
  fontDescriptions = builtins.map buildToml fontFormats;
in
  stdenv.mkDerivation rec {
    pname = "openmoji";
    version = "14.0.0";
    src = fetchFromGitHub {
      owner = "hfg-gmuend";
      repo = pname;
      rev = version;
      hash = "sha256-XnSRSlWXOMeSaO6dKaOloRg3+sWS4BSaro4bPqOyKmE=";
    };

    nativeBuildInputs = [
      nanoemoji
      gettext # for envsubst
    ];

    inherit fontFormats fontDescriptions;

    buildPhase = ''
      runHook preBuild

      mkdir -p build/color
      for toml in $fontDescriptions; do
        source="$(pwd)" envsubst '$source' < $toml > "build/color/$(basename $toml)"
      done

      nanoemoji --build_dir="build/color" "build/color/"*.toml

      for method in $fontFormats; do
        mkdir -p build/fonts/OpenMoji-color-$method
        cp build/color/OpenMoji-color-$method.ttf build/fonts/OpenMoji-color-$method/
      done

      for colr_version in 0 1; do
        if ! [ -d "build/fonts/OpenMoji-color-glyf_colr_''${colr_version}" ];
          continue;
        fi
        mkdir -p build/fonts/OpenMoji-color-colr''${colr_version}_svg/
        cp \
          "build/fonts/OpenMoji-color-glyf_colr_''${colr_version}/OpenMoji-color-glyf_colr_''${colr_version}.ttf" \
          build/fonts/OpenMoji-color-colr''${colr_version}_svg/OpenMoji-color-colr''${colr_version}_svg.ttf

        maximum_color build/fonts/OpenMoji-color-colr''${colr_version}_svg/OpenMoji-color-colr''${colr_version}_svg.ttf
      done

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fonts/truetype"
      cp build/fonts/*/*.ttf "$out/share/fonts/truetype"

      runHook postInstall
    '';
  }
