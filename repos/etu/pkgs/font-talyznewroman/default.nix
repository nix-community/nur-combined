{
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation {
  pname = "talyznewroman";
  version = "1";

  src = fetchurl {
    url = "https://talyz.github.io/talyz-new-roman/font/TalyzNewRoman.ttf";
    sha256 = "00pi45pwmm1mialb643ifvp2qf6rhgwkmbk9malmyac815abpb0g";
  };

  dontUnpack = true;

  installPhase = "install --mode=644 -D $src $out/share/fonts/truetype/talyz-new-roman.ttf";

  meta = with lib; {
    description = "talyz's terrible font";
    homepage = "https://talyz.github.io/talyz-new-roman";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
