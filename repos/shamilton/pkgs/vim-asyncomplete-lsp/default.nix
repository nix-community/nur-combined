{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:

buildVimPluginFrom2Nix {
  pname = "vim-asyncomplete-lsp";
  version = "2020-06-27";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "asyncomplete-lsp.vim";
    rev = "684c34453db9dcbed5dbf4769aaa6521530a23e0";
    sha256 = "0vqx0d6iks7c0liplh3x8vgvffpljfs1j3g2yap7as6wyvq621rq";
  };

  meta = with lib; {
    description = "LSP source for asyncomplete.vim vim-lsp";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/asyncomplete-lsp.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
