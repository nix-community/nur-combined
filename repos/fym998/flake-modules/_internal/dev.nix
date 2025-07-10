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
  };
  partitions.${devPartitionName} = {
    extraInputsFlake = ../../dev;
    module = {
      imports = [ ../../dev/partition-module.nix ];
    };
  };
}
