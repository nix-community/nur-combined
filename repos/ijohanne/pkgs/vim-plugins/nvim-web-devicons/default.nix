{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "nvim-web-devicons";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-web-devicons) owner repo rev sha256;
  };
}
