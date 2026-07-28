final: prev:
let
  inherit (prev) lib;
in
{
  # from https://github.com/NixOS/nixpkgs/pull/314654
  interception-tools =
    if (builtins.any (lib.hasSuffix "-udevmon-path-fix.patch") prev.interception-tools.patches) then
      prev.interception-tools
    else
      prev.interception-tools.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./interception-tools-udevmon-path-fix.patch ];
      });
}
