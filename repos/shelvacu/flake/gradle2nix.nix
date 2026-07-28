{ ... }: {
  vacuBuilds.gradle2nix = {
    multiSystem = true;
    putInPackages = true;
  };

  perSystem = { pkgs, ... }: { vacuBuildDerivations.gradle2nix = pkgs.gradle2nix; };
}
