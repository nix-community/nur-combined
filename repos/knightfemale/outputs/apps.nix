{
  perSystem =
    {
      lib,
      self',
      ...
    }:
    {
      apps =
        lib.mapAttrs
          (name: _: {
            type = "app";
            meta.description = self'.packages.${name}.meta.description;
            program = lib.getExe self'.packages.${name};
          })
          (
            builtins.intersectAttrs (lib.genAttrs [
              "biu"
              "comfyui-workflow-mcp"
              "flake-show-ng"
            ] (_: null)) self'.packages
          );
    };
}
