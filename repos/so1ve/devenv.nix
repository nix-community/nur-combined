{ inputs, pkgs, ... }:

let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixRepinSource = builtins.fetchTree flakeLock.nodes.nix-repin.locked;
  nixRepin = pkgs.callPackage "${nixRepinSource}/default.nix" { };
in
{
  overlays = [ inputs.js-toolchain-overlay.overlays.default ];

  languages.javascript = {
    enable = true;
    package = pkgs.node-bin.majors."26";
    lsp.package = pkgs.vtsls;
  };

  files."tsconfig.json".json.extends = "${nixRepin}/share/nix-repin/tsconfig.consumer.json";

  packages = with pkgs; [
    actionlint
    nixfmt-tree
    prettierd
    vscode-langservers-extracted
  ];
}
