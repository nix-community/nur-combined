{ lib, fetchurl }:
pinFile: system:
let
  pin = lib.importJSON pinFile;
  values =
    (pin.vars or { })
    // {
      inherit (pin) version;
    }
    // lib.optionalAttrs (pin ? arch) {
      arch = pin.arch.${system} or (throw "${toString pinFile}: no arch entry for ${system}");
    };
  names = builtins.attrNames values;
  url = builtins.replaceStrings (map (name: "{${name}}") names) (map (
    name: values.${name}
  ) names) pin.url;
in
{
  inherit (pin) version;
  platforms = builtins.attrNames pin.hash;
  src = fetchurl {
    inherit url;
    hash = pin.hash.${system} or (throw "${toString pinFile}: no hash for ${system}");
  };
}
