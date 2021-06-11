{ lib
, fetchFromGitHub
, buildVimPluginFrom2Nix
, vim-async
}:
buildVimPluginFrom2Nix rec {

  pname = "vim-lsp";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "vim-lsp";
    rev = "v${version}";
    sha256 = "1x9rb34a9542rn2dx2kaz4iq83swpq56144h81pr8l080r6vi2l6";
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
