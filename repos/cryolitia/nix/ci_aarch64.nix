let
  outputs = builtins.getFlake (toString ../.);
  pkgs = outputs.inputs.nixpkgs;
  drvs = pkgs.lib.collect pkgs.lib.isDerivation outputs.ciJobs."aarch64-linux";
in
drvs
