{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.nixosConfigurations = {
    lem = withSystem "x86_64-linux" (
      { pkgs, system, ... }:
      inputs.nixpkgs.lib.nixosSystem rec {
        inherit system pkgs;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          inputs.self.nixosModules.eownerdead
          ./lem
        ];
      }
    );

    slate = withSystem "x86_64-linux" (
      { pkgs, system, ... }:
      inputs.nixpkgs.lib.nixosSystem rec {
        inherit system pkgs;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          inputs.self.nixosModules.eownerdead
          ./slate
        ];
      }
    );
  };
}
