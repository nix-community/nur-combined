{
  meta,
  src,
  updateScript,
  stdenvNoCC,
  pkgs,
  lib,
}:

let
  inherit (pkgs.python312Packages) fontmake gftools;

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-code-vf";
  version = "git-${lib.strings.substring 0 7 finalAttrs.src.rev}";
  src = src;

  buildPhase = ''
    runHook preBuild

    export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

    family_name="Fira Code"
    glyphs_file="${src}/FiraCode.glyphs"

    dir=$(pwd)
    file="$dir/FiraCode-VF.ttf"
    mkdir -p "$dir"

    echo "=============="
    echo
    echo "  [i] Creating variable font file!"
    echo

    vf_glyphs="$dir/vf.glyphs"

    awk '/name = Retina;/ { print; print "exports = 0;"; next }1' \
      "$glyphs_file" > "$vf_glyphs"

    ${fontmake}/bin/fontmake -g "$vf_glyphs" -o variable --output-path "$file"

    # other fixes for metadata and hinting
    ${gftools}/bin/gftools fix-nonhinting "$file" "$file.fix"
    mv "$file.fix" "$file"

    ${gftools}/bin/gftools fix-gasp --autofix "$file"
    mv "$file.fix" "$file"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype FiraCode-VF.ttf

    runHook postInstall
  '';

  passthru = {
    inherit updateScript;
  };

  inherit meta;
})
