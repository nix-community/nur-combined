# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

_self: super:

let

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

  overlay =
    builtins.listToAttrs
      (map (n: nameValuePair n nurAttrs.${n})
        (builtins.filter (n: !isReserved n)
          (builtins.attrNames nurAttrs)));

in

# Shadow existing package sets if they already exist rather than replacing.
overlay //
{
  goModules = (super.goModules or { }) // (overlay.goModules or { });
  jetbrains = (super.jetbrains or { }) // (overlay.jetbrains or { });
  python2Packages = (super.python2Packages or { }) // (overlay.python2Packages or { });
  python3Packages = (super.python3Packages or { }) // (overlay.python3Packages or { });
}
