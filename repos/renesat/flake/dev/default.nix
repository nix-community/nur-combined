{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
    inputs.devshell.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    pkgs,
    config,
    ...
  }: {
    treefmt.programs = {
      alejandra.enable = true;
    };

    pre-commit.settings.hooks = {
      treefmt = {
        enable = true;
        package = config.treefmt.build.wrapper;
      };
      deadnix.enable = true;
      statix.enable = true;
    };

    devshells.default = {
      packages = [];

      commands = [
        {
          package = config.treefmt.build.wrapper;
          help = "Code formatter";
        }
        {
          package = pkgs.nix-tree;
          help = "Interactively browse dependency graphs of Nix derivations";
        }
        {
          package = pkgs.nvd;
          help = "Diff two nix toplevels and show which packages were upgraded";
        }
        {
          package = pkgs.nix-diff;
          help = "Explain why two Nix derivations differ";
        }
        {
          package = pkgs.nix-output-monitor;
          help = "Nix Output Monitor (a drop-in alternative for `nix` which shows a build graph)";
        }
        {
          package = pkgs.nix-update;
          help = "Nix utils for update packages";
        }
      ];

      devshell.startup.pre-commit.text = config.pre-commit.installationScript;

      env = [
      ];
    };
  };
}
