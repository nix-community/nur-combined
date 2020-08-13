{ pkgs
, lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix {

  pname = "vim-async";
  version = "2020-03-17";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "async.vim";
    rev = "42371b5fb2cc07254295ff6beb3ca7cf235b7ede";
    sha256 = "1c6ymxm28hpai1ki5y5a2m6qh5129nqn1fxiq9xnlzfrlbjl8vil";
  };

  meta = with lib; {
    description = "Normalize async job control api for vim and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/async.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
