{ self }:
let
  inherit (self) inputs;

  # Package Sets
  inherit (self.inputs) stable unstable;

  # Extra modules
  inherit (self.inputs) home-manager firefox-darwin nur;

  # This is required for any system needing to reference the flake itself from
  # within the nixosSystem config. It will be available as an argument to the 
  # config as "flake" if used as defined below
  inherit (self.common) self-reference users home-manager-modules options;

  inherit (self.common.system) stable-darwin-system unstable-darwin-system;

  inherit (self.common.package-sets)
    aarch64-darwin-stable aarch64-darwin-unstable x86_64-darwin-stable
    x86_64-darwin-unstable;
in {
  # Hosts
  cloyster = let
    inherit (x86_64-darwin-stable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/cloyster ];
  in stable-darwin-system { inherit system pkgs modules; };

  ninetales = let
    inherit (aarch64-darwin-unstable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/ninetales ];
  in unstable-darwin-system { inherit system pkgs modules; };

  victreebel = let
    inherit (aarch64-darwin-stable) system identifier pkgs;
    base = self.common.modules.${identifier};
    modules = base ++ [ ../hosts/victreebel ];
  in stable-darwin-system { inherit system pkgs modules; };
}
