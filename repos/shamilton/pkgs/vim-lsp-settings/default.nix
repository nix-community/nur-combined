{ lib
, fetchFromGitHub
, buildVimPlugin
, vim-async
, vim-lsp
, vim-asyncomplete
, vim-asyncomplete-lsp
}:
buildVimPlugin rec {

  pname = "vim-lsp-settings";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "vim-lsp-settings";
    rev = "v${version}";
    sha256 = "1wvvqjpngxh07v2ka0qjf56my6hrjqk1i7jwismy2cmfj0br60xn";
  };

  buildInputs =           [ vim-async vim-lsp vim-asyncomplete vim-asyncomplete-lsp ];
  propagatedBuildInputs = [ vim-async vim-lsp vim-asyncomplete vim-asyncomplete-lsp ];

  meta = with lib; {
    description = "Auto configurations for Language Server for vim-lsp";
    license = licenses.mit;
    homepage = "https://github.com/mattn/vim-lsp-settings";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
