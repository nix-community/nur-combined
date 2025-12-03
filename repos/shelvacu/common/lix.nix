{ vacuModuleType, ... }:
if vacuModuleType == "nixos" then
  {
    # imports = [ inputs.lix-module.nixosModules.default ];
  }
else
  { }
