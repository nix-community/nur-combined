{
  self,
  ...
}:
{
  flake.nixosModules = self.lib.modulesFromDirectoryRecursive {
    directory = ../modules/nixos;
  };
}
