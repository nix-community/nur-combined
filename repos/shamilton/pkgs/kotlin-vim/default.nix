{ lib
, buildVimPlugin
, fetchFromGitHub
}:

buildVimPlugin {
  pname = "kotlin-vim";
  version = "2022-12-30";

  src = fetchFromGitHub {
    owner = "udalov";
    repo = "kotlin-vim";
    rev = "53fe045906df8eeb07cb77b078fc93acda6c90b8";
    sha256 = "sha256-Eiwn2nQxb92gmcf3M5JW4HEnr9Uljyj5Sg/MA7Nc7ro=";
  };

  meta = with lib; {
    description = "Kotlin plugin for Vim";
    license = licenses.asl20;
    homepage = "https://github.com/udalov/kotlin-vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
