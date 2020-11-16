{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "ranger-vim";
  src = pkgs.fetchFromGitHub {
    inherit (sources.ranger-vim) owner repo rev sha256;
  };
}
