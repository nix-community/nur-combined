{
  lib,
  stdenvNoCC,
  python3,
  vista-fonts,
}:

stdenvNoCC.mkDerivation {
  pname = "consolas-nl";
  version = "1.0";

  dontUnpack = true;

  nativeBuildInputs = [
    (python3.withPackages (ps: [ ps.fonttools ]))
  ];

  buildPhase =
    let
      src = "${vista-fonts}/share/fonts/truetype";
      patch = ./patch.py;
    in
    ''
      python ${patch} ${src}/consola.ttf  ConsolasNL-Regular.ttf
      python ${patch} ${src}/consolab.ttf ConsolasNL-Bold.ttf
      python ${patch} ${src}/consolai.ttf ConsolasNL-Italic.ttf
      python ${patch} ${src}/consolaz.ttf ConsolasNL-BoldItalic.ttf
    '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/consolas-nl
    cp ConsolasNL-*.ttf $out/share/fonts/truetype/consolas-nl/
  '';

  meta = with lib; {
    description = "Consolas patched for Linux HiDPI: TrueType hints stripped, vertical metrics corrected, family renamed to Consolas NL";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
