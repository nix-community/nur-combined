# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

self: super:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules" || n == "fishPlugins" || n == "vimPlugins" || n == "firefoxPlugins" || n == "sddmThemes";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

in
builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
    (builtins.filter (n: !isReserved n)
      (builtins.attrNames nurAttrs)))
  // {
  vimPlugins = (super.vimPlugins or { }) // nurAttrs.vimPlugins;
  fishPlugins = (super.fishPlugins or { }) // nurAttrs.fishPlugins;
  firefoxPlugins = (super.firefoxPlugins or { }) // nurAttrs.firefoxPlugins;
  sddmThemes = (super.sddmThemes or { }) // nurAttrs.sddmThemes;
}
