{
  inputs,
  perSystem,
  ...
}: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
  ];
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: rec {
    pre-commit.check.enable = true;

    devShells.default = with pkgs;
      mkShell {
        name = "pkgs";
        mods = [];
        buildInputs = [
          nix-output-monitor
        ];
        shellHook = ''
          ENVRC=pkgs
          ${config.pre-commit.devShell.shellHook}
        '';
      };

    pre-commit.settings.hooks = {
      #nixpkgs-fmt.enable = true;
      alejandra.enable = true; # https://github.com/kamadorueda/alejandra/blob/main/integrations/pre-commit-hooks-nix/README.md
      prettier.enable = true;
      trailing-whitespace = {
        enable = true;
        name = "trim trailing whitespace";
        entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/trailing-whitespace-fixer";
        types = ["text"];
        stages = ["commit" "push" "manual"];
      };
      check-merge-conflict = {
        enable = true;
        name = "check for merge conflicts";
        entry = "${pkgs.python3.pkgs.pre-commit-hooks}/bin/check-merge-conflict";
        types = ["text"];
      };
    };
  };
}
