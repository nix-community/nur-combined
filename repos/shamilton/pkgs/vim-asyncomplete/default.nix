{ pkgs
, lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix rec {

  pname = "vim-asyncomplete";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "prabirshrestha";
    repo = "asyncomplete.vim";
    rev = "v${version}";
    sha256 = "1zcl8nbybzxj3rfb3rgnb41xysxhxh1y7888w0d2s1qcmzigca68";
  };

  meta = with lib; {
    description = "Async completion in pure vim script for vim8 and neovim";
    license = licenses.mit;
    homepage = "https://github.com/prabirshrestha/asyncomplete.vim";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
