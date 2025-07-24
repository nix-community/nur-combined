{ inputs, ... }:

let
  devPartitionName = "dev";
in
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
  ];
  partitionedAttrs = {
    devShells = devPartitionName;
    checks = devPartitionName;
    formatter = devPartitionName;
    files = devPartitionName;
  };
  partitions.${devPartitionName} = {
    extraInputsFlake = ./.;
    module = {
      imports = [ ./partition-module.nix ];
    };
  };
}
