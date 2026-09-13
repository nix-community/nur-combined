{ inputs, pkgs, ... }:

let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixRepinSource = builtins.fetchTree flakeLock.nodes.nix-repin.locked;
  nixRepinConfig = builtins.fromJSON (builtins.readFile "${nixRepinSource}/deno.json");
in
{
  overlays = [ inputs.js-toolchain-overlay.overlays.default ];

  languages.deno = {
    enable = true;
    package = pkgs.deno-bin.latest;
  };

  files."deno.json".json = {
    imports = nixRepinConfig.imports // {
      "nix-repin" = "file://${nixRepinSource}/src/mod.ts";
    };
    lock = {
      path = "${nixRepinSource}/deno.lock";
      frozen = true;
    };
    nodeModulesDir = "none";
  };

  packages = with pkgs; [
    actionlint
    nixfmt-tree
    vscode-langservers-extracted
  ];
}
