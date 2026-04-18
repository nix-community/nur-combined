{
  lib,
  fetchurl,
  stdenvNoCC,
  file,
  ...
}: {
  # Pixiv illustration ID (required)
  id,
  # Page number, 0-based (default: 0 = first page)
  p ? 0,
  # Hash of the image file (required, SRI format like sha256-...)
  hash,
  # Mirror domains to try, in order
  mirrors ? [
    "pixiv.re"
    "pixiv.cat"
    "pixiv.nl"
  ],
  saveToshare ? true,
}: let
  isValidId =
    (lib.isInt id && id > 0) || (lib.isString id && builtins.match "^[1-9][0-9]*$" id != null);

  idString = toString id;

  isNonEmptyString = value: lib.isString value && value != "";

  # Mirrors use first-page routes without a suffix and numbered routes with
  # 1-based pages, while the public API exposes Pixiv-style 0-based page indices.
  # jpg is not the true extension, but it can fetch png or gif images as well.
  possiblePaths =
    if p == 0
    then [
      "${idString}.jpg"
      "${idString}-1.jpg"
    ]
    else ["${idString}-${toString (p + 1)}.jpg"];

  # Generate all URL candidates: route variants first, then mirrors.
  urls = lib.concatMap (path: map (mirror: "https://${mirror}/${path}") mirrors) possiblePaths;
in
  assert isValidId;
  assert lib.isInt p && p >= 0;
  assert builtins.isList mirrors && mirrors != [] && builtins.all isNonEmptyString mirrors; let
    rawPixiv = fetchurl {
      inherit urls hash;
    };
  in
    if !saveToshare
    then let
      tmpPixiv = stdenvNoCC.mkDerivation {
        name = "pixiv-${idString}-p${toString p}";
        src = rawPixiv;
        nativeBuildInputs = [file];
        dontUnpack = true;
        dontBuild = true;
        dontFixup = true;
        installPhase = ''
          # Detect real image type via file(1) and rename accordingly
          mime=$(file -b --mime-type "$src")
          case "$mime" in
            image/jpeg) ext="jpg" ;;
            image/png)  ext="png" ;;
            image/gif)  ext="gif" ;;
            *)          ext="jpg" ;;
          esac
          mkdir -p "$out"
          ln -s "$src" "$out/${idString}-p${toString p}.$ext"
          echo $ext > "$out/extension.txt"
        '';
      };
    in
      stdenvNoCC.mkDerivation {
        name = "pixiv-${idString}-p${toString p}.${
          lib.removeSuffix "\n" (builtins.readFile "${tmpPixiv}/extension.txt")
        }";
        dontUnpack = true;
        dontBuild = true;
        dontFixup = true;
        src = tmpPixiv;
        installPhase = ''
          ln -s "$src/${idString}-p${toString p}".* "$out"
        '';
      }
    else
      stdenvNoCC.mkDerivation {
        name = "pixiv-${idString}-p${toString p}";
        dontUnpack = true;
        dontBuild = true;
        dontFixup = true;
        nativeBuildInputs = [file];
        src = rawPixiv;
        installPhase = ''
          # Detect real image type via file(1) and rename accordingly
          mime=$(file -b --mime-type "$src")
          case "$mime" in
            image/jpeg) ext="jpg" ;;
            image/png)  ext="png" ;;
            image/gif)  ext="gif" ;;
            *)          ext="jpg" ;;
          esac
          mkdir -p "$out/share/pixiv"
          ln -s "$src" "$out/share/pixiv/${idString}-p${toString p}.$ext"
        '';
      }
