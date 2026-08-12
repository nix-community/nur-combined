{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix rec {
  pname = "vim-racket";
  version = "2020-06-24";

  src = fetchFromGitHub {
    owner = "wlangstroth";
    repo = pname;
    rev = "bca2643c3d8bd0fcd46ab73bee69023a5da1964b";
    sha256 = "sha256-XqbR9qMvvaeZ7LHUemocJQQ/CaJSHxEwh7B7Y1o6KhU=";
  };
}
