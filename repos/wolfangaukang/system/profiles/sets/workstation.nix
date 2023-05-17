{ inputs
, lib
, ...
}:

let
  inherit (inputs) self;
  inherit (lib) mkForce optionals;
  system-lib = import "${self}/system/lib" { inherit inputs; };
  inherit (system-lib) obtainIPV4Address obtainIPV4GatewayAddress;

in {
  imports = [
    ./common.nix
    ./gui.nix
    "${self}/system/profiles/networking.nix"
    "${self}/system/profiles/rfkill.nix"
    "${self}/system/profiles/time.nix"
    "${self}/system/profiles/flatpak.nix"
    "${self}/system/profiles/services/openssh.nix"
    "${self}/system/profiles/services/zerotier.nix"
  ];
}
