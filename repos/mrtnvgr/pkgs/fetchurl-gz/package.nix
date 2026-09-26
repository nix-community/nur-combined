{ stdenvNoCC, fetchurl, lib, zstd }:
{ ... } @ args:
let
  inherit (builtins) length hasAttr head baseNameOf;
  inherit (lib) removeSuffix take last;

  url = if hasAttr "url" args then args.url else head args.urls;
  tmpFilename = if hasAttr "extension" args then "download.${args.extension}" else baseNameOf url;

  removeSuffixes = suffixes: value: let
    len = length suffixes;
  in
    if (len == 0) then value
    else removeSuffixes (take (len - 1) suffixes) (removeSuffix (last suffixes) value);
in fetchurl ({
  name = removeSuffixes [ ".zst" ] tmpFilename;

  nativeBuildInputs = [ zstd ];
  postFetch = ''
    TMPFILE=$TMPDIR/${tmpFilename}
    mv "$downloadedFile" "$TMPFILE"

    [[ "$TMPFILE" =~ \.zst$ ]] && zstd --rm -d "$TMPFILE" -o $out
  '';

  downloadToTemp = true;
  recursiveHash = true;
} // args)
