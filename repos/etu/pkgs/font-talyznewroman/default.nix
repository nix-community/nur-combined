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
    hash = "sha256-D6y7VAmIKV+pqmmuOvmD2Tgs7nZxELOoijXUym8h8QI=";
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
