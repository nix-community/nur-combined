{ inputs
, ...
}:

let
  inherit (inputs) self;

in {
  imports = [
    # TODO: Handle DE dynamically
    "${self}/system/profiles/de/pantheon.nix"
    "${self}/system/profiles/graphics.nix"
  ];
}
