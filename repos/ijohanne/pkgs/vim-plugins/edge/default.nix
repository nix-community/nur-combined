{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "edge";
  src = pkgs.fetchFromGitHub {
    inherit (sources.edge) owner repo rev sha256;
  };
}
