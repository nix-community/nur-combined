{ inputs, ... }: {
  flake =
    let
      inherit (import ../lib.nix inputs) base;
    in
    {
      nixosConfigurations = {
        nixos = inputs.nixpkgs.lib.nixosSystem
          (
            let
              pkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
              };
            in
            {
              inherit pkgs;
              specialArgs = { user = "nixos"; };
              modules = [
              ]
              ++ (import ./additions.nix (base // { inherit pkgs; }));
            }
          );
      };
    };
}
