{ stdenv, makeWrapper, symlinkJoin, lilypond, openlilylib-fonts, fonts }:
let
  _fonts = openlilylib-fonts.override { inherit lilypond; };

  getFont = fontName:
    if builtins.hasAttr fontName _fonts
    then builtins.getAttr fontName _fonts
    else throw "${fontName} is not a known font";

  fontPaths = map getFont fonts;
in
symlinkJoin {
  name = (stdenv.lib.appendToName "with-fonts" lilypond).name;
  inherit (lilypond) meta version;

  paths = [ lilypond ] ++ fontPaths;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for program in $out/bin/*; do
        wrapProgram "$program" \
            --set LILYPOND_DATADIR "$out/share/lilypond/${lilypond.version}"
    done
  '';
}
