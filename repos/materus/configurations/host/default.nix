{ inputs, materusFlake }:

let
  profiles = import ../profile;
in
{
  materusPC = inputs.nixpkgs.lib.nixosSystem rec {
    specialArgs = { inherit inputs; inherit materusFlake; };
    system = "x86_64-linux";
    modules = [
      ./materusPC
      inputs.private.systemModule
      profiles.osProfile
    ];
  };
  flamaster = inputs.nixpkgs.lib.nixosSystem rec {
    specialArgs = { inherit inputs; inherit materusFlake; };
    system = "x86_64-linux";
    modules = [
      ./flamaster
      inputs.private.systemModule
      profiles.osProfile

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.materus = { config ,... }: {
          imports = [
            ../home/materus
            flamaster/extraHome.nix
            profiles.homeProfile
            inputs.private.homeModule
          ];
          materus.profile.nixpkgs.enable = false;
        };
        home-manager.extraSpecialArgs = { inherit inputs; inherit materusFlake; };
      }
    ];
  };
  valkyrie = inputs.nixpkgs.lib.nixosSystem rec {
    specialArgs = { inherit inputs; inherit materusFlake; };
    system = "x86_64-linux";
    modules = [
      ./valkyrie
      inputs.private.systemModule
      profiles.osProfile
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.materus = { config ,... }: {
          imports = [
            ../home/materus
            valkyrie/extraHome.nix
            profiles.homeProfile
            inputs.private.homeModule
          ];
          materus.profile.nixpkgs.enable = false;
        };
        home-manager.extraSpecialArgs = { inherit inputs; inherit materusFlake; };
      }
    ];
  };

}
