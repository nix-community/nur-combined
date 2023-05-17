{ inputs
, ...
}:

let
  inherit (inputs) self;

in {
  imports = [
    "${self}/system/profiles/console.nix"
    "${self}/system/profiles/environment.nix"
    "${self}/system/profiles/layouts.nix"
    "${self}/system/profiles/security.nix"
    "${self}/system/profiles/users.nix"
  ];

  programs.firejail.enable = true;
}
