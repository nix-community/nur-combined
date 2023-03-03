{ inputs
, hostname
, ...
}:

let
  inherit (inputs) self;

in {
  imports = [
    "${self}/system/profiles/console.nix"
    "${self}/system/profiles/de/pantheon.nix"
    "${self}/system/profiles/environment.nix"
    "${self}/system/profiles/flatpak.nix"
    "${self}/system/profiles/graphics.nix"
    "${self}/system/profiles/layouts.nix"
    "${self}/system/profiles/networking.nix"
    "${self}/system/profiles/rfkill.nix"
    "${self}/system/profiles/security.nix"
    "${self}/system/profiles/time.nix"
    "${self}/system/profiles/users.nix"
    (import "${self}/system/profiles/services/openssh.nix" { inherit inputs hostname; })
  ];
}
