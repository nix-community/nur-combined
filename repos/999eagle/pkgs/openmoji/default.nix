{
  stdenv,
  fetchFromGitHub,
  nanoemoji,
  gettext,
  runCommand,
  xmlstarlet,
  python3,
  woff2,
  # font configuration options
  # available color formats: ["cbdt" "glyf_colr_0" "glyf_colr_1" "sbix" "picosvgz" "untouchedsvgz"]
  fontFormats ? ["cbdt" "glyf_colr_0" "glyf_colr_1"],
  ascender ? "1045",
  descender ? "-275",
}: let
  buildToml = method: let
    saturation = "color";
  in
    runCommand "OpenMoji-${saturation}-${method}.toml" {
      inherit method saturation ascender descender;
      toml = ./build.toml;
    } ''
      ${gettext}/bin/envsubst '$method $saturation $ascender $descender' < $toml > $out
    '';
  fontDescriptions = builtins.map buildToml fontFormats;

  basicFonts = stdenv.mkDerivation rec {
    pname = "openmoji-base";
    version = "unstable-2023-11-08";
    src = fetchFromGitHub {
      owner = "hfg-gmuend";
      repo = "openmoji";
      rev = "c3596a904058f739735c092cdcdaf4535082e849";
      hash = "sha256-GukmdutPp4HGX6s/lMgNaazB5ahvWwvmEdfjSGseBiQ=";
    };

    outputs = ["out" "cache"];

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

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fonts/truetype"
      cp build/fonts/*.ttf "$out/share/fonts/truetype"

      mkdir -p "$out/share/fonts/woff2"
      cp build/fonts/*.woff2 "$out/share/fonts/woff2"

      mkdir -p "$cache/build/"
      cp -a build/color/ $cache/build/

      runHook postInstall
    '';
  };
in
  stdenv.mkDerivation {
    pname = "openmoji";
    inherit (basicFonts) version;
    srcs = [basicFonts.out basicFonts.cache];
    sourceRoot = basicFonts.name;

    nativeBuildInputs = [
      nanoemoji
      woff2
    ];

    postUnpack = ''
      echo "restoring cache"
      mkdir -p ${basicFonts.name}/build/
      cp -r ${basicFonts.name}-cache/build/color/ ${basicFonts.name}/build/
      chmod -R u+w ${basicFonts.name}/build/
    '';

    buildPhase = ''
      runHook preBuild

      for colr_version in 0 1; do
        if ! [ -f "share/fonts/truetype/OpenMoji-color-glyf_colr_''${colr_version}.ttf" ]; then
          continue
        fi

        maximum_color \
          --build_dir="build/color" \
          "share/fonts/truetype/OpenMoji-color-glyf_colr_''${colr_version}.ttf" \
          --output_file "$(pwd)/build/fonts/OpenMoji-color-colr''${colr_version}_svg.ttf"

        woff2_compress build/fonts/OpenMoji-color-colr''${colr_version}_svg.ttf

        maximum_color \
          --build_dir="build/color" --bitmaps \
          "share/fonts/truetype/OpenMoji-color-glyf_colr_''${colr_version}.ttf" \
          --output_file "$(pwd)/build/fonts/OpenMoji-color-cbdt_colr''${colr_version}_svg.ttf"

        woff2_compress build/fonts/OpenMoji-color-cbdt_colr''${colr_version}_svg.ttf
      done

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fonts/truetype"
      cp build/fonts/*.ttf "$out/share/fonts/truetype"
      cp share/fonts/truetype/*.ttf $out/share/fonts/truetype

      mkdir -p "$out/share/fonts/woff2"
      cp build/fonts/*.woff2 "$out/share/fonts/woff2"
      cp share/fonts/woff2/*.woff2 $out/share/fonts/woff2

      runHook postInstall
    '';
  }
