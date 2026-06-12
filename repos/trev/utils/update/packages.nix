{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  packages =
    pkgs.lib.filterAttrs (_: package: pkgs.lib.meta.availableOn { inherit system; } package)
      (
        import ../../packages {
          inherit system pkgs;
        }
      );

  hasUpdateScript =
    drv:
    pkgs.lib.isDerivation drv
    # contains a valid updateScript
    && (builtins.hasAttr "updateScript" drv && builtins.isList drv.updateScript);

  collectUpdateScripts =
    path: value:
    if pkgs.lib.isDerivation value then
      (pkgs.lib.optionalAttrs (hasUpdateScript value) {
        ${pkgs.lib.concatStringsSep "." path} = pkgs.lib.concatStringsSep " " value.updateScript;
      })
      // collectUpdateScripts (path ++ [ "extensions" ]) (value.passthru.extensions or { })
    else if builtins.isAttrs value then
      pkgs.lib.concatMapAttrs (name: collectUpdateScripts (path ++ [ name ])) value
    else
      { };
in
{
  packages = pkgs.lib.concatMapAttrs (name: collectUpdateScripts [ name ]) packages;
}
