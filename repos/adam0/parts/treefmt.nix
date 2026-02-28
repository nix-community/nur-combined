{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _: {
    treefmt.programs = {
      alejandra.enable = true;
      nixf-diagnose.enable = true;
      deadnix.enable = true;
      statix.enable = true;

      rumdl-check.enable = true;
      rumdl-format.enable = true;
    };
  };
}
