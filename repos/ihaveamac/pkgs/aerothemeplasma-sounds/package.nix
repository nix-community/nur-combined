{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:

stdenvNoCC.mkDerivation rec {
  pname = "aerothemeplasma-sounds";
  version = "0";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/${pname}";
    rev = "55d2f5fd15f53cccbbb13388941b930442db1159";
    hash = "sha256-z73owMl2+mAQJKGgjuJAmPIYOYuoVug0nWZ3WqWY0DY=";
  };

  installPhase = ''
    mkdir -p $out/share/sounds
    rm README.md LICENSE CMakeLists.txt .gitignore
    cp -r * $out/share/sounds/
  '';

  # useless phase that takes forever, this is just images
  dontFixup = true;
}
