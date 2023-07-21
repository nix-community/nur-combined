{
  stdenv,
  fetchFromGitHub,
  nanoemoji,
  gettext,
  runCommand,
  #fontFormats ? ["cbdt" "glyf_colr_0" "glyf_colr_1" "sbix" "picosvgz" "untouchedsvgz"],
  fontFormats ? ["cbdt" "glyf_colr_0" "glyf_colr_1"],
  xmlstarlet,
  python3,
  woff2,
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
    version = "unstable-2023-06-14";
    src = fetchFromGitHub {
      owner = "hfg-gmuend";
      repo = pname;
      rev = "7fe6c3dbc6b353ea9cbceb5bb0d4641912d520a1";
      hash = "sha256-NQnti2b7iCRrMk4i3j5CUjVzat8tL3AdaCToIhleCWk=";
    };

    nativeBuildInputs = [
      nanoemoji
      gettext # for envsubst
      xmlstarlet
      python3.pkgs.fonttools
      woff2
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
        cp data/OpenMoji-Color.ttx build/color/OpenMoji-color-$method.ttx
        xmlstarlet edit --inplace --update \
          '/ttFont/name/namerecord[@nameID="5"][@platformID="3"]' \
          --value "${version}" \
          build/color/OpenMoji-color-$method.ttx

        mkdir -p build/fonts/

        ttx \
          -m build/color/OpenMoji-color-$method.ttf \
          -o build/fonts/OpenMoji-color-$method.ttf \
          build/color/OpenMoji-color-$method.ttx

        woff2_compress build/fonts/OpenMoji-color-$method.ttf
      done

      for colr_version in 0 1; do
        if ! [ -f "build/fonts/OpenMoji-color-glyf_colr_''${colr_version}.ttf" ]; then
          continue
        fi

        maximum_color \
          "build/fonts/OpenMoji-color-glyf_colr_''${colr_version}.ttf" \
          --output_file "$(pwd)/build/fonts/OpenMoji-color-colr''${colr_version}_svg.ttf"

        woff2_compress build/fonts/OpenMoji-color-colr''${colr_version}_svg.ttf
      done

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fonts/truetype"
      cp build/fonts/*.ttf "$out/share/fonts/truetype"

      mkdir -p "$out/share/fonts/woff2"
      cp build/fonts/*.woff2 "$out/share/fonts/woff2"

      runHook postInstall
    '';
  }
