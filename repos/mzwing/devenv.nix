{
  inputs,
  pkgs,
  ...
}: let
  # Resolve source.ts imports against the nix-repin revision flake.lock pins.
  nix-repin-source = builtins.fetchTree (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nix-repin.locked;
  nix-repin = pkgs.callPackage "${nix-repin-source}/default.nix" {};
in {
  languages.nix = {
    enable = true;
    lsp.enable = true;
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_26;
  };

  files."tsconfig.ts.json".json.extends = "${nix-repin}/share/nix-repin/tsconfig.consumer.json";

  packages =
    (with pkgs; [
      act
      actionlint
      alejandra
      just
      nixd
      prettier
      ruff
      shellcheck
      shfmt
      typescript
    ])
    ++ (with inputs.nur-packages.packages.${pkgs.stdenv.hostPlatform.system}; [
      typenix
    ]);

  cachix.pull = ["mzwing"];

  enterTest = ''
    act --version
    actionlint -version
    alejandra --version
    just --version
    nixd --version
    node --version
    prettier --version
    tsc --version
    typenix --version
  '';
}
