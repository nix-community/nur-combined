{
  lib,
  stdenvNoCC,
  python3,
  vista-fonts,
  nerd-fonts,
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
      src   = "${vista-fonts}/share/fonts/truetype";
      nfDir = "${nerd-fonts.dejavu-sans-mono}/share/fonts/truetype/NerdFonts/DejaVuSansM";
      patch = ./patch.py;
    in
    ''
      python ${patch} ${src}/consola.ttf  ConsolasNL-Regular.ttf    ${nfDir}/DejaVuSansMNerdFontMono-Regular.ttf
      python ${patch} ${src}/consolab.ttf ConsolasNL-Bold.ttf        ${nfDir}/DejaVuSansMNerdFontMono-Bold.ttf
      python ${patch} ${src}/consolai.ttf ConsolasNL-Italic.ttf      ${nfDir}/DejaVuSansMNerdFontMono-Oblique.ttf
      python ${patch} ${src}/consolaz.ttf ConsolasNL-BoldItalic.ttf  ${nfDir}/DejaVuSansMNerdFontMono-BoldOblique.ttf
    '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/consolas-nl
    cp ConsolasNL-*.ttf $out/share/fonts/truetype/consolas-nl/
  '';

  meta = with lib; {
    description = "Consolas patched for HiDPI: TrueType hints stripped, vertical metrics corrected, box drawing added, family renamed to Consolas NL";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
