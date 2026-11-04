{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      packages = builtins.intersectAttrs (lib.genAttrs [
        "biu"
        "comfyui-workflow-mcp"
        "flake-show-ng"
      ] (_: null)) pkgs;
    };
}
