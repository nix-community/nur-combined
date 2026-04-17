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
            (nixos."age/${name}" or { }) # secret accompany with host
            (nixos."net/${name}" or { })
            (nixos."disko/${name}" or { })
            (nixos."backup/${name}" or { })
            (nixos."caddy/${name}" or { })
            (nixos."bird/${name}" or { })
          ];
      }
    );

    checks =
      config.flake.nixosConfigurations
      |> lib.mapAttrsToList (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "configurations:nixos:${name}" = nixos.config.system.build.toplevel;
          };
        }
      )
      |> lib.mkMerge;
  };
}
