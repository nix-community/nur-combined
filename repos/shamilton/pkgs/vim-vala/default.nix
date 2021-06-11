{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix {

  pname = "vala";
  version = "2020-05-02";

  src = fetchFromGitHub {
    owner = "arrufat";
    repo = "vala.vim";
    rev = "ce569e187bf8f9b506692ef08c10b584595f8e2d";
    sha256 = "143aq0vxa465jrwajs9psk920bm6spn9ga24f5qdai926hhp2gyl";
  };

  meta = with lib; {
    description = "Vala syntax highlighting, indentation, snippets and more for Vim";
    license = licenses.gpl3;
    homepage = "https://github.com/arrufat/vala.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
