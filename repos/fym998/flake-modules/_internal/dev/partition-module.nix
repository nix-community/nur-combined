{
  inputs,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.make-shell.flakeModules.default
    inputs.files.flakeModules.default
    ./files
  ];
  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      treefmt = {
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          yamlfmt = {
            enable = true;
            settings.formatter = {
              retain_line_breaks = true;
            };
          };
        };
      };
      pre-commit = {
        check.enable = false;
        settings.hooks = {
          treefmt.enable = true;
          files =
            let
              writerCfg = config.files.writer;
              writerPkg = writerCfg.drv;
            in
            {
              enable = true;
              package = writerPkg;
              entry = "${writerPkg}/bin/${writerCfg.exeFilename}";
            };
        };
      };
      make-shells.default = {
        imports =
          builtins.map
            (
              shellModule:
              builtins.intersectAttrs (lib.genAttrs [
                "buildInputs"
                "nativeBuildInputs"
                "propagatedBuildInputs"
                "propagatedNativeBuildInputs"
                "shellHook"
              ] (_: null)) shellModule
            )
            [
              config.treefmt.build.devShell
              config.pre-commit.devShell
            ];
        nativeBuildInputs = builtins.attrValues {
          inherit (pkgs)
            nil
            nix-prefetch-git
            nix-fast-build
            nix-eval-jobs

            yaml2json
            jq
            ;
        };
      };
    };
}
