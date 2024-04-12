{ inputs }:

let
  self =
    { hostname
    , username
    , system
    , inputs
    , overlays ? [ ]
    , channel ? inputs.nixpkgs
    , pkgs ? channel.legacyPackages.${system}
    }:

    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;

    in
    homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit username inputs; };
      modules = [
        "${inputs.self}/home/users/${username}/${hostname}.nix"
        "${inputs.self}/home/modules/personal"
        {
          home = {
            username = username;
            homeDirectory = "/home/${username}";
          };
          nixpkgs.overlays = overlays;
        }
      ];
    };
in
self
