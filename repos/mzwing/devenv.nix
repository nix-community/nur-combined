{
  inputs,
  pkgs,
  ...
}: let
  # Resolve source.ts imports against the nix-repin revision flake.lock pins.
  nix-repin = builtins.fetchTree (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nix-repin.locked;
in {
  languages.nix = {
    enable = true;
    lsp.enable = true;
  };

  languages.deno.enable = true;

  files."deno.json".json = {
    imports = (builtins.fromJSON (builtins.readFile "${nix-repin}/deno.json")).imports // {nix-repin = "file://${nix-repin}/src/mod.ts";};
    lock = {
      path = "${nix-repin}/deno.lock";
      frozen = true;
    };
    nodeModulesDir = "none";
  };

  packages =
    (with pkgs; [
      act
      actionlint
      alejandra
      just
      nixd
      ruff
      shellcheck
      shfmt
    ])
    ++ (with inputs.nur-packages.packages.${pkgs.stdenv.hostPlatform.system}; [
      typenix
    ]);

  cachix.pull = ["mzwing"];

  enterTest = ''
    act --version
    actionlint -version
    alejandra --version
    deno --version
    just --version
    nixd --version
    typenix --version
  '';
}
