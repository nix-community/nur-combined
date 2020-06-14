{ pkgs
, lib
, fetchFromGitHub
, buildVimPluginFrom2Nix
, vim-async
}:
buildVimPluginFrom2Nix rec {

  pname = "vim-lsp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "vim-lsp";
    rev = "v${version}";
    sha256 = "14dy0y671z6xir7i8i01k8lwws9dl0z3l41v57a00a43hya6s9fp";
  };

  buildInputs = [ vim-async ];
  propagatedInputs = [ vim-async ];

  meta = with lib; {
    description = "Async language server protocol plugin for vim and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/vim-lsp";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
