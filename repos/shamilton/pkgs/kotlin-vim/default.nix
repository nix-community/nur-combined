{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
}:

buildVimPluginFrom2Nix {
  pname = "kotlin";
  version = "2021-04-20";

  src = fetchFromGitHub {
    owner = "udalov";
    repo = "kotlin-vim";
    rev = "e043f6a2ddcb0611e4afcb1871260a520e475c74";
    sha256 = "0ygvicf8gcaskz33qkfl1yg1jiv0l9cyp8fn2rrnzdsb7amsss0v";
  };

  meta = with lib; {
    description = "Kotlin plugin for Vim";
    license = licenses.asl20;
    homepage = "https://github.com/udalov/kotlin-vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
