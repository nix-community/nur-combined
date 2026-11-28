final: prev:
let
  inherit (prev.stdenv.hostPlatform)
    isLinux
    ;
in
{
  biu = if isLinux then final.callPackage ../_packages/biu { } else null;

  comfyui-workflow-mcp = final.callPackage ../_packages/comfyui-workflow-mcp { };

  flake-show-ng = final.callPackage ../_packages/flake-show-ng { };
}
