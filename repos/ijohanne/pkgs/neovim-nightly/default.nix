{ pkgs, sources, ... }:
pkgs.neovim-unwrapped.overrideAttrs (attrs: {
  pname = "neovim-nightly";
  version = "master";
  nativeBuildInputs = attrs.nativeBuildInputs
    ++ [ pkgs.tree-sitter ];
  src = pkgs.fetchFromGitHub {
    inherit (sources.neovim) owner repo rev sha256;
  };
})
