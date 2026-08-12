{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix rec {
  pname = "vim-simplicity";
  version = "2020-01-26";

  src = fetchFromGitHub {
    owner = "smallwat3r";
    repo = pname;
    rev = "3913c2a1d7e1cfd1d318ebc458700e48db4f9412";
    sha256 = "sha256-z77UBG0nwSob56wAIio7iiTL8Z6qHUG+BfN5dkrdvT0=";
  };
}
