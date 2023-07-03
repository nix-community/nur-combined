{ inputs
, ...
}:

let
  inherit (inputs) self;

in {
  imports = [
    # TODO: Handle DE dynamically
    "${self}/system/profiles/services/de/pantheon.nix"
    "${self}/system/profiles/hardware/graphics.nix"
  ];
}
