{stdenv, fetchFromGitHub, lib}:
stdenv.mkDerivation {
  pname = "latex-chinese-fonts";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "Haixing-Hu";
    repo = "latex-chinese-fonts";
    rev = "1466c733b66d83ad2287228a94fd86b6ad9efa48";
    sha256 = "mchW+hwbXPvx0V/hqXcyBF5uBoqOLAAYmFVW78i8Mzc=";
  };
  installPhase = ''
    mkdir -p $out/share/fonts/latex-chinese-fonts
    cp -r chinese $out/share/fonts/latex-chinese-fonts
    cp -r english $out/share/fonts/latex-chinese-fonts
  '';
  meta = with lib; {
    description = "Simplified Chinese fonts for the LaTeX typesetting.";
    homepage = "https://github.com/Haixing-Hu/latex-chinese-fonts";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = with licenses; [ mit ];
  };
}
