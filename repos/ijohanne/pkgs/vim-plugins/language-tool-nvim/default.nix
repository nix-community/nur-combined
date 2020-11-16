{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "language-tool-nvim";
  src = pkgs.fetchFromGitHub {
    inherit (sources.LanguageTool-nvim) owner repo rev sha256;
  };
}
