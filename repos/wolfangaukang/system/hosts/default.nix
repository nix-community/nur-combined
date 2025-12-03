{
  inputs,
  overlays,
  localLib,
}:

let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) attrsets nixosSystem;
  hosts = attrsets.genAttrs [ "arenal" "irazu" ] (
    hostname:
    nixosSystem {
      modules = [ "${self}/system/hosts/${hostname}" ];
      specialArgs = {
        inherit
          inputs
          localLib
          overlays
          hostname
          ;
      };
    }
  );

in
hosts
// {
  vm =
    let
      hostname = "pocosol";
    in
    nixosSystem {
      modules = [ "${self}/system/hosts/${hostname}" ];
      specialArgs = {
        inherit
          inputs
          localLib
          overlays
          hostname
          ;
      };
    };
}
