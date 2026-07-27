{
  inputs,
  localLib,
  overlays,
  os ? "",
}:

let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.nix-darwin.lib) darwinSystem;

  linux_hosts = inputs.nixpkgs.lib.attrsets.genAttrs [ "arenal" "irazu" ] (
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
  darwin_hosts =
    let
      tenorio_base = {
        system = "aarch64-darwin";
        modules = [ "${self}/system/hosts/tenorio" ];
        specialArgs = {
          hostname = "tenorio";
          overlays = overlays ++ [ inputs.nix-darwin.overlays.default ];
          inherit inputs localLib;
        };
      };

    in
    {
      tenorio = darwinSystem tenorio_base;
      tenorio-work = darwinSystem (
        tenorio_base
        // {
          modules = tenorio_base.modules ++ [
            { home-manager.users.bjorn.personaj.work.simplerisk.enable = inputs.nixpkgs.lib.mkForce true; }
          ];
        }
      );
    };
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

in
if os == "darwin" then darwin_hosts else (linux_hosts // vm)
