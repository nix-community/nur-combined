{
  self,
  inputs,
  withSystem,
  ...
}:
let
  mkHost =
    hostName:
    {
      system ? "x86_64-linux",
      modules ? [ ],
      overlays ? builtins.attrValues self.overlays,
      nixosModules ? builtins.attrValues self.nixosModules,
      homeModules ? builtins.attrValues self.homeModules,
      withHome ? true,
    }:
    withSystem system (
      { ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = homeModules;
              extraSpecialArgs = { inherit inputs self; };
            };
            nixpkgs.overlays = overlays;
            networking.hostName = hostName;
          }

          ../hosts/common
          ../hosts/${hostName}
        ]
        ++ (if withHome then [ ../home ] else [ ])
        ++ nixosModules
        ++ modules;

        specialArgs = { inherit inputs self; };
      }
    );
in
{
  flake.nixosConfigurations = {
    laptop = mkHost "laptop" {
      modules = with inputs; [
        nixos-hardware.nixosModules.common-cpu-amd-pstate
        nixos-hardware.nixosModules.common-gpu-amd
      ];
    };
  };
}
