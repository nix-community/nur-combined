{
  inputs,
  system,
  user,
  ...
}:

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
        inputs.android-nixpkgs.hmModule
        inputs.anyrun.homeManagerModules.default
        inputs.catppuccin.homeManagerModules.catppuccin
      ];
    };
    extraSpecialArgs = {
      inherit inputs system user;
    };
  };
}
