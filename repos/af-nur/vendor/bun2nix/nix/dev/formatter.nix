{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    settings.global.excludes = [
      "*.envrc"
      "*.envrc."
    ];

    programs = {
      deadnix.enable = true;
      mdformat.enable = true;
      nixfmt.enable = true;
      prettier.enable = true;
      rustfmt.enable = true;
      shellcheck.enable = true;
      shfmt.enable = true;
      statix.enable = true;
      toml-sort.enable = true;
      zig.enable = true;
      mix-format.enable = true;
    };
  };
}
