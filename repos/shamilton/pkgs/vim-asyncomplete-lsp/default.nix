{ lib
, buildVimPlugin
, fetchFromGitHub
, coreutils
}:

buildVimPlugin {
  pname = "vim-asyncomplete-lsp";
  version = "2022-11-21";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "asyncomplete-lsp.vim";
    rev = "cc5247bc268fb2c79d8b127bd772514554efb3ee";
    sha256 = "sha256-SeEAy/jtrdHerZPVjQZXANTcuvMndIIWgGh3B8Ik1NM=";
  };

  meta = with lib; {
    description = "LSP source for asyncomplete.vim vim-lsp";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/asyncomplete-lsp.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
