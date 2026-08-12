{ self, ... }:
{
  imports = [ self.inputs.sops-nix.nixosModules.sops ];

}
