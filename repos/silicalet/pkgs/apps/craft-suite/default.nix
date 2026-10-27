{
  callPackage,
  lib,
  symlinkJoin,
}:
let
  packages = lib.mapAttrs' (
    appName: description:
    lib.nameValuePair "${appName}-bin" (callPackage ./binary.nix { inherit appName description; })
  ) (import ./catalog.nix);
in
packages
// {
  craft-suite-bin = symlinkJoin {
    name = "craft-suite-bin";
    paths = builtins.attrValues packages;
    meta = {
      description = "The thirteen ArtCraft creative applications and their launcher";
      homepage = "https://getartcraft.com/apps";
      license = with lib.licenses; [
        mit
        asl20
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };
}
