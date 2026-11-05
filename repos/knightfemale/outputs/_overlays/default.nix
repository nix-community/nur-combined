final: prev:
let
  inherit (prev.stdenv.hostPlatform)
    isAarch64
    isLinux
    ;
in
{
  biu = if isLinux then final.callPackage ../_packages/biu { } else null;
  comfyui-workflow-mcp = final.callPackage ../_packages/comfyui-workflow-mcp { };
  deviceTrees =
    if (isLinux && isAarch64) then final.callPackage ../_legacyPackages/deviceTrees { } else null;
  flake-show-ng = final.callPackage ../_packages/flake-show-ng { };
}
