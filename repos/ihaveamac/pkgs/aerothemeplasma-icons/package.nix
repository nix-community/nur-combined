{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:

stdenvNoCC.mkDerivation rec {
  pname = "aerothemeplasma-icons";
  version = "0";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/${pname}";
    rev = "b8d5ce100251b74a3a3c5b4a474cb3ff8df11bba";
    hash = "sha256-4GFn8wJ8b58AwZZAyt7/0R1JTcJtamoocPjr31c8Nk4=";
  };

  installPhase = ''
    mkdir -p $out/share/icons
    rm README.md LICENSE CMakeLists.txt .gitignore
    cp -r * $out/share/icons/
  '';

  # useless phase that takes forever, this is just images
  dontFixup = true;
}
