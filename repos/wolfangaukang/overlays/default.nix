{ inputs }:

let
  mkChannelOverlay =
    {
      input,
      attrName,
      config ? { },
    }:
    (final: prev: {
      ${attrName} = import input {
        inherit config;
        system = prev.stdenv.hostPlatform.system;
      };
    });
  overlays = [
    (import ./local-apps.nix)
    (import ./shnsplit-24w.nix)
    (import ./wayland.nix)
  ];

in
overlays
