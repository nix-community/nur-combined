{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "git-blame-nvim";
  src = pkgs.fetchFromGitHub {
    inherit (sources.git-blame-nvim) owner repo rev sha256;
  };
}
