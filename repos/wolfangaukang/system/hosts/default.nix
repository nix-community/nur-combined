{ inputs, overlays, localLib }:

let
  inherit (localLib) mkNixos;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  baseUsers = {
    system = [ "root" "bjorn" ];
    hm = [ "bjorn" ];
  };

in
{
  arenal = nixosSystem {
    modules = [ ./arenal ];
    specialArgs = { inherit inputs localLib overlays; hostname = "arenal"; };
  };

  irazu = nixosSystem {
    modules = [ ./irazu ];
    specialArgs = { inherit inputs localLib overlays; hostname = "irazu"; };
  };

  barva = mkNixos {
    inherit inputs overlays;
    users = baseUsers.system;
    hostname = "barva";
    enable-impermanence = true;
    enable-sops = true;
    enable-hm = true;
    hm-users = baseUsers.hm;
    enable-sops-hm = true;
  };

  chopo =
    let
      users = [ "nixos" ];
    in
    mkNixos {
      inherit inputs overlays users;
      hostname = "chopo";
      hm-users = users;
      extra-special-args = { inherit users; };
    };

  vm = nixosSystem {
    modules = [ ./pocosol ];
    specialArgs = { inherit inputs localLib overlays; hostname = "pocosol"; };
  };
}
