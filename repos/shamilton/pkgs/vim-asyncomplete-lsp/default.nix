{ pkgs
, lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix {

  pname = "vim-asyncomplete-lsp";
  version = "2020-05-25";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "asyncomplete-lsp.vim";
    rev = "0357e956fa143b3824c6a032c5b6c9b7ef744c23";
    sha256 = "10cccsfp435is42q0n2bbpccl2lppda2adjv4i7z3hkjk55azr6j";
  };

  meta = with lib; {
    description = "LSP source for asyncomplete.vim vim-lsp";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/asyncomplete-lsp.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
