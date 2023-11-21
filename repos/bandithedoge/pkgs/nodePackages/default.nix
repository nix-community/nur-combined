{pkgs, ...}: let
  nodeDeps = pkgs.callPackage ./_node2nix/default.nix {nodejs = pkgs.nodejs_latest;};
in {
  inherit (nodeDeps) emmet-ls;

  tailwindcss-language-server = nodeDeps."@tailwindcss/language-server";
  emmet-language-server = nodeDeps."@olrtg/emmet-language-server";
}
