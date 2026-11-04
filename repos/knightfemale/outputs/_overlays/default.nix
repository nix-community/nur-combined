{
  lib,
}:

final: prev:
let
  inherit (prev.stdenv.hostPlatform)
    isAarch64
    isLinux
    ;
in
{
  comfyui-workflow-mcp = final.callPackage ../_packages/comfyui-workflow-mcp { };
  flake-show-ng = final.callPackage ../_packages/flake-show-ng { };
}
// lib.optionalAttrs isLinux {
  biu = final.callPackage ../_packages/biu { };
}
// lib.optionalAttrs (isLinux && isAarch64) {
  deviceTrees = final.callPackage ../_legacyPackages/deviceTrees { };
}
