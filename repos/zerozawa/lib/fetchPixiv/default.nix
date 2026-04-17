{
  lib,
  fetchurl,
  stdenv,
  ...
}: {
  # Pixiv illustration ID (required)
  id,
  # Page number, 0-based (default: 0 = first page)
  p ? 0,
  # SHA256 hash of the image (required)
  sha256,
  # Mirror domains to try, in order
  mirrors ? [
    "pixiv.re"
    "pixiv.cat"
    "pixiv.nl"
  ],
  # Image extensions to try, in order of likelihood
  extensions ? [
    "jpg"
    "png"
    "gif"
    "jpeg"
  ],
}: let
  isValidId =
    (lib.isInt id && id > 0) || (lib.isString id && builtins.match "^[1-9][0-9]*$" id != null);

  idString = toString id;

  isNonEmptyString = value: lib.isString value && value != "";
  normalizedExtensions = map lib.toLower extensions;

  # Mirrors use first-page routes without a suffix and numbered routes with
  # 1-based pages, while the public API exposes Pixiv-style 0-based page indices.
  mkPaths = ext:
    if p == 0
    then [
      "${idString}.${ext}"
      "${idString}-1.${ext}"
    ]
    else ["${idString}-${toString (p + 1)}.${ext}"];

  # Generate all URL candidates: extensions first, then route variants, then mirrors.
  urls =
    lib.concatMap (
      ext: lib.concatMap (path: map (mirror: "https://${mirror}/${path}") mirrors) (mkPaths ext)
    )
    normalizedExtensions;
in
  # Validation
  assert isValidId;
  assert lib.isInt p && p >= 0;
  assert builtins.isList mirrors && mirrors != [] && builtins.all isNonEmptyString mirrors;
  assert builtins.isList extensions && extensions != [] && builtins.all isNonEmptyString extensions; let
    tmpPixiv = fetchurl {
      inherit urls;
      inherit sha256;
    };
    PixivExtension = lib.head (lib.filter (ext: builtins.elem ext normalizedExtensions) extensions);
    finalPxiv = stdenv.mkDerivation {
      name = "pixiv-${idString}-p${toString p}.${PixivExtension}";
      src = tmpPixiv;
      dontUnpack = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        ln -s $src $out
      '';
    };
  in
    finalPxiv
