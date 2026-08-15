{
  # keep-sorted start
  bash,
  clickgen,
  fetchFromTangled,
  fetchurl,
  hyprcursor,
  lib,
  ouch,
  python3,
  stdenvNoCC,
  xcur2png,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    fromJSON
    readFile
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    mapAttrs
    recurseIntoAttrs
    # keep-sorted end
    ;

  release = fromJSON (readFile ./release.json);
  inherit
    (release)
    # keep-sorted start
    palettes
    variants
    version
    # keep-sorted end
    ;

  src = fetchFromTangled {
    did = "did:plc:v3hmlmsytt6b2zvi3e35o2oj/bibata-cursor";
    tag = version;
    hash = release.sourceHash;
  };

  mkMeta = description:
    with lib; {
      inherit description;
      homepage = "https://tangled.org/did:plc:v3hmlmsytt6b2zvi3e35o2oj/bibata-cursor";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };

  mkHyprcursor = cursor: variantName: variant: paletteName: palette: let
    themeName = "Bibata-${variant.shape}-${palette.themeName}${variant.suffix}";
    description = "${palette.displayName} Bibata ${variant.displayName} Hyprcursor theme";
  in
    stdenvNoCC.mkDerivation {
      pname = "bibata-${variantName}-cursors-${paletteName}-hyprcursor";
      inherit
        # keep-sorted start
        src
        version
        # keep-sorted end
        ;

      nativeBuildInputs = [
        # keep-sorted start
        bash
        hyprcursor
        python3
        xcur2png
        # keep-sorted end
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p bin
        cp -r ${cursor}/share/icons/${themeName} bin/
        chmod -R u+w bin
        bash scripts/build-hyprcursor.sh

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        install -dm0755 "$out/share/icons"
        cp -r "bin/${themeName}-hyprcursor" "$out/share/icons/"

        runHook postInstall
      '';

      meta = mkMeta description;
    };

  mkCursor = variantName: variant: paletteName: palette: let
    themeName = "Bibata-${variant.shape}-${palette.themeName}${variant.suffix}";
    description = "${palette.displayName} Bibata ${variant.displayName} XCursor theme";

    bitmaps = fetchurl {
      url = "https://tangled.org/did:plc:v3hmlmsytt6b2zvi3e35o2oj/bibata-cursor/tags/${release.tagHash}/download/${themeName}.zip";
      hash = release.hashes.${themeName};
    };

    hyprcursorPackage =
      mkHyprcursor
      cursor
      variantName
      variant
      paletteName
      palette;

    cursor = stdenvNoCC.mkDerivation {
      pname = "bibata-${variantName}-cursors-${paletteName}";
      inherit
        # keep-sorted start
        src
        version
        # keep-sorted end
        ;

      nativeBuildInputs = [
        # keep-sorted start
        clickgen
        ouch
        # keep-sorted end
      ];

      buildPhase = ''
        runHook preBuild

        mkdir bitmap-root
        ouch decompress --yes --dir bitmap-root ${bitmaps}
        ctgen ${variant.buildFile} \
          -d "bitmap-root/${themeName}" \
          -n "${themeName}" \
          -c "${description}"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        install -dm0755 "$out/share/icons"
        cp -r "bin/${themeName}" "$out/share/icons/"

        runHook postInstall
      '';

      passthru = {
        ciPackages = [hyprcursorPackage];
        hyprcursor = hyprcursorPackage;
        updateScript = null;
      };

      meta = mkMeta description;
    };
  in
    cursor;

  mkVariant = variantName: variant:
    recurseIntoAttrs {
      cursors = recurseIntoAttrs (mapAttrs (mkCursor variantName variant) palettes);
    };
in
  mapAttrs mkVariant variants
