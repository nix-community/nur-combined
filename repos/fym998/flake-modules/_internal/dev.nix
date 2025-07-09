{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
  ];
  partitionedAttrs =
    let
      devPartitionName = "dev";
    in
    {
      devShells = devPartitionName;
      checks = devPartitionName;
      formatter = devPartitionName;
    };
  partitions.dev = {
    extraInputsFlake = ../../dev;
    module = {
      imports = [ ../../dev/partition-module.nix ];
    };
  };
}
