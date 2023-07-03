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
    "${self}/system/profiles/base"
    ./gui.nix
    "${self}/system/profiles/hardware/rfkill.nix"
    "${self}/system/profiles/services/flatpak.nix"
    "${self}/system/profiles/services/openssh.nix"
    "${self}/system/profiles/services/zerotier.nix"
    "${self}/system/profiles/system/networking.nix"
    "${self}/system/profiles/system/time.nix"
  ];
}
