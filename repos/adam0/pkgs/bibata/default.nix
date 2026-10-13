{
  # keep-sorted start
  clickgen,
  fetchFromTangled,
  hyprcursor,
  lib,
  python3,
  resvg,
  stdenvNoCC,
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

  sourceAttrs = {
    inherit src version;
  };

  mkMeta = description:
    with lib; {
      inherit description;
      homepage = "https://tangled.org/did:plc:v3hmlmsytt6b2zvi3e35o2oj/bibata-cursor";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };

  mkHyprcursor = variantName: variant: paletteName: palette: let
    themeName = "Bibata-${variant.shape}-${palette.themeName}${variant.suffix}";
    description = "${palette.displayName} Bibata ${variant.displayName} Hyprcursor theme";
  in
    stdenvNoCC.mkDerivation (sourceAttrs
      // {
        pname = "bibata-${variantName}-cursors-${paletteName}-hyprcursor";
        nativeBuildInputs = [
          # keep-sorted start
          hyprcursor
          python3
          # keep-sorted end
        ];

        buildPhase = ''
          runHook preBuild

          python3 scripts/build-hyprcursor.py --theme "${themeName}" --version "${version}"

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          install -dm0755 "$out/share/icons"
          cp -r "bin/${themeName}-hyprcursor" "$out/share/icons/"

          runHook postInstall
        '';

        doInstallCheck = true;
        installCheckPhase = ''
          runHook preInstallCheck
          python3 ${./check-hyprcursor.py} "$out/share/icons/${themeName}-hyprcursor" ${variant.buildFile} ${lib.getLib hyprcursor}/lib/libhyprcursor.so
          runHook postInstallCheck
        '';

        meta = mkMeta description;
      });

  mkCursor = variantName: variant: paletteName: palette: let
    themeName = "Bibata-${variant.shape}-${palette.themeName}${variant.suffix}";
    description = "${palette.displayName} Bibata ${variant.displayName} XCursor and scalable SVG theme";

    hyprcursorPackage =
      mkHyprcursor
      variantName
      variant
      paletteName
      palette;

    cursor = stdenvNoCC.mkDerivation (sourceAttrs
      // {
        pname = "bibata-${variantName}-cursors-${paletteName}";
        nativeBuildInputs = [
          # keep-sorted start
          clickgen
          python3
          resvg
          # keep-sorted end
        ];

        buildPhase = ''
          runHook preBuild

          python3 scripts/build-scalable.py --theme "${themeName}" --output scalable
          python3 scripts/build-bitmaps.py --theme "${themeName}"
          ctgen ${variant.buildFile} -d "bitmaps/${themeName}" -n "${themeName}" -c "${description}"
          cp -r "scalable/${themeName}/cursors_scalable" "bin/${themeName}/"

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          install -dm0755 "$out/share/icons"
          cp -r "bin/${themeName}" "$out/share/icons/"

          runHook postInstall
        '';

        doInstallCheck = true;
        installCheckPhase = ''
          runHook preInstallCheck
          python3 ${./check-installed.py} "$out/share/icons/${themeName}" ${variant.buildFile}
          runHook postInstallCheck
        '';

        passthru = {
          ciPackages = [hyprcursorPackage];
          hyprcursor = hyprcursorPackage;
          updateScript = null;
        };

        meta = mkMeta description;
      });
  in
    cursor;

  mkVariant = variantName: variant:
    recurseIntoAttrs {
      cursors = recurseIntoAttrs (mapAttrs (mkCursor variantName variant) palettes);
    };
in
  mapAttrs mkVariant variants
