{
  lib,
  stdenvNoCC,
  python3,
  vista-fonts,
  nerd-fonts,
  julia-mono,
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
      nfDir = "${nerd-fonts.dejavu-sans-mono}/share/fonts/truetype/NerdFonts/DejaVuSansM";
      jmDir = "${julia-mono}/share/fonts/truetype";
      patch = ./patch.py;
    in
    ''
      python ${patch} ${src}/consola.ttf  ConsolasNL-Regular.ttf    ${jmDir}/JuliaMono-Regular.ttf       ${nfDir}/DejaVuSansMNerdFontMono-Regular.ttf
      python ${patch} ${src}/consolab.ttf ConsolasNL-Bold.ttf       ${jmDir}/JuliaMono-Bold.ttf          ${nfDir}/DejaVuSansMNerdFontMono-Bold.ttf
      python ${patch} ${src}/consolai.ttf ConsolasNL-Italic.ttf     ${jmDir}/JuliaMono-RegularItalic.ttf ${nfDir}/DejaVuSansMNerdFontMono-Oblique.ttf
      python ${patch} ${src}/consolaz.ttf ConsolasNL-BoldItalic.ttf ${jmDir}/JuliaMono-BoldItalic.ttf    ${nfDir}/DejaVuSansMNerdFontMono-BoldOblique.ttf
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
