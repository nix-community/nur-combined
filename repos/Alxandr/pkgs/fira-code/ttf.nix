{
  meta,
  src,
  updateScript,
  stdenvNoCC,
  pkgs,
  lib,
}:

let
  inherit (pkgs) ttfautohint;
  inherit (pkgs.python312Packages) fontmake;

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-code-ttf";
  version = "git-${lib.strings.substring 0 7 finalAttrs.src.rev}";
  src = src;

  buildPhase = ''
    runHook preBuild

    family_name="Fira Code"
    glyphs_file="${src}/FiraCode.glyphs"

    dir=$(pwd)
    mkdir -p "$dir"

    weights=( "Light" "Regular" "Retina" "Medium" "SemiBold" "Bold" )
    for weight in "''${weights[@]}"; do
      file="$dir/FiraCode-$weight.ttf"

      echo "=============="
      echo
      echo "  [i] Creating $file"
      echo

      ${fontmake}/bin/fontmake -g "$glyphs_file" -o ttf --output-path "$file" -i ".* $weight"
      echo "  [i] TTFautohint $file"
      ${ttfautohint}/bin/ttfautohint --no-info --ignore-restrictions "$file" "$file.hinted"
      mv "$file.hinted" "$file"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype *.ttf

    runHook postInstall
  '';

  passthru = {
    inherit updateScript;
  };

  inherit meta;
})
