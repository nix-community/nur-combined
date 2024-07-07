{ lib
, buildVimPlugin
, fetchFromGitHub
, coreutils
}:
buildVimPlugin rec {

  pname = "vim-asyncomplete";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "asyncomplete.vim";
    rev = "v${version}";
    sha256 = "1l23rfaddajkbra582k38ak5l0qwfdr6ac84abh3l1912ljfp7ih";
  };

  meta = with lib; {
    description = "Async completion in pure vim script for vim8 and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/asyncomplete.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
