{
  inputs,
  lib,
  config,
  ...
}:
{
  options.os = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
        };
      }
    );
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.os (
      name:
      { module }:
      inputs.nixpkgs.lib.nixosSystem {
        modules =
          let
            nixos = config.flake.modules.nixos;
          in
          [
            module
            (if nixos ? "age/${name}" then nixos."age/${name}" else { }) # secret accompany with host
            (if nixos ? "net/${name}" then nixos."net/${name}" else { })
            (if nixos ? "disko/${name}" then nixos."disko/${name}" else { })
            (if nixos ? "backup/${name}" then nixos."backup/${name}" else { })
            (if nixos ? "caddy/${name}" then nixos."caddy/${name}" else { })
            (if nixos ? "bird/${name}" then nixos."bird/${name}" else { })
          ];
      }
    );

    # checks =
    #   config.flake.nixosConfigurations
    #   |> lib.mapAttrsToList (
    #     name: nixos: {
    #       ${nixos.config.nixpkgs.hostPlatform.system} = {
    #         "configurations:nixos:${name}" = nixos.config.system.build.toplevel;
    #       };
    #     }
    #   )
    #   |> lib.mkMerge;
  };
}
