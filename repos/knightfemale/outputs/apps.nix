{
  perSystem =
    {
      lib,
      pkgs,
      ...
    }:
    {
      apps =
        lib.mapAttrs
          (name: pkg: {
            type = "app";
            meta.description = pkg.meta.description;
            program = lib.getExe pkg;
          })
          (
            lib.filterAttrs (_: pkg: pkg != null) {
              inherit (pkgs)
                biu
                comfyui-workflow-mcp
                flake-show-ng
                lada
                ;
            }
          );
    };
}
