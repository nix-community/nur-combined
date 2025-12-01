{ pkgs }:
let
  # from https://docs.deno.com/runtime/reference/cli/compile/#supported-targets
  targets = [
    {
      name = "x86_64-darwin";
      normalized = "x86_64-darwin";
    }
    {
      name = "aarch64-darwin";
      normalized = "aarch64-darwin";
    }
    {
      name = "gnu64";
      normalized = "x86_64-linux";
    }
    {
      name = "aarch64-multiplatform";
      normalized = "aarch64-linux";
    }
  ];
in
builtins.listToAttrs (
  builtins.map (
    target:
    pkgs.lib.attrsets.nameValuePair "docker-${target.normalized}" (
      drv:
      pkgs.pkgsCross."${target.name}".callPackage ./default.nix {
        drv = drv.override (
          previous: builtins.mapAttrs (name: value: pkgs.pkgsCross."${target.name}"."${name}") previous
        );
        pkgs = pkgs.pkgsCross."${target.name}";
      }
    )
  ) targets
)
