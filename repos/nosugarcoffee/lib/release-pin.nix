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
  # {arch} is filled only for the system this pin was loaded for. Extra
  # files (a skills archive, for example) share the version and the vars
  # but are not per-system, so their URLs simply never mention {arch}.
  substitute =
    template:
    builtins.replaceStrings (map (name: "{${name}}") names) (map (name: values.${name}) names) template;
in
{
  inherit (pin) version;
  platforms = builtins.attrNames pin.hash;
  src = fetchurl {
    url = substitute pin.url;
    hash = pin.hash.${system} or (throw "${toString pinFile}: no hash for ${system}");
  };
  files = lib.mapAttrs (
    _: file:
    fetchurl {
      url = substitute file.url;
      inherit (file) hash;
    }
  ) (pin.files or { });
}
// lib.optionalAttrs (pin ? arch) { inherit (values) arch; }
