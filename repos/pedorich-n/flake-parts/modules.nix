{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  flake.modules = {
    nixos = self.lib.modulesFromDirectoryRecursive {
      directory = ../modules/nixos;
    };
  };
}
