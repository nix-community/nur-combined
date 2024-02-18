{ inputs, system, user, ... }:


let
  homeProfile = ./home.nix;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = {
      imports = [
        homeProfile
        inputs.hyprland.homeManagerModules.default
        inputs.android-nixpkgs.hmModule
        inputs.anyrun.homeManagerModules.default
        #        
      ];
    };
    extraSpecialArgs = { inherit inputs system user; };
  };

}
