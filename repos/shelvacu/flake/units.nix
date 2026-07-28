{ ... }: {
  vacuBuilds.units = {
    aliases = [ "vacu-units" ];
    putInPackages = true;
  };
  perSystem = { plainEval, ... }: {
    vacuBuildDerivations.units = plainEval.config.vacu.units.finalPackage;
  };
}
