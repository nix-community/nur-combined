{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nextvi";
  version = "2022-09-05";

  src = fetchFromGitHub {
    owner = "kyx0r";
    repo = "nextvi";
    rev = "5ccc9f3a18be9d78a72a91c432ab3aac50c69647";
    hash = "sha256-GqTN6kbBVksh1uXUTGs2unyl2GXlz+Vogqr0kLcIgGs=";
  };

  buildPhase = ''
    runHook preBuild
    sh ./build.sh
    runHook postBuild
  '';

  installPhase = ''
    PREFIX=$out sh ./build.sh install
  '';

  meta = with lib; {
    description = "Next version of neatvi (a small vi/ex editor)";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
