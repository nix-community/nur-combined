{ ... }: {
  vacuBuilds.vacuWrappedSops = {
    aliases = [
      "sops"
      "wrappedSops"
    ];
    putInPackages = true;
  };
  perSystem = { pkgs, ... }: { vacuBuildDerivations = { inherit (pkgs) vacuWrappedSops; }; };
}
