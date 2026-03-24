# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

final: prev:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules" || n == "fishPlugins" || n == "vimPlugins" || n == "firefoxPlugins" || n == "sddmThemes";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = prev; };

in
builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
    (builtins.filter (n: !isReserved n)
      (builtins.attrNames nurAttrs)))
  // {
  vimPlugins = (prev.vimPlugins or { }) // nurAttrs.vimPlugins;
  fishPlugins = (prev.fishPlugins or { }) // nurAttrs.fishPlugins;
  firefoxPlugins = (prev.firefoxPlugins or { }) // nurAttrs.firefoxPlugins;
  sddmThemes = (prev.sddmThemes or { }) // nurAttrs.sddmThemes;
}
