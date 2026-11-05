{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      packages = lib.filterAttrs (_: v: v != null) {
        inherit (pkgs)
          biu
          comfyui-workflow-mcp
          flake-show-ng
          ;
      };
    };
}
