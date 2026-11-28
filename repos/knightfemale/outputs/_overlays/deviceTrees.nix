final: prev:
let
  inherit (prev.stdenv.hostPlatform)
    isAarch64
    isLinux
    ;

  deviceTreesRaw = final.callPackage ../_legacyPackages/deviceTrees { };
in
{
  inherit
    deviceTreesRaw
    ;

  deviceTrees = if (isLinux && isAarch64) then deviceTreesRaw else null;
}
