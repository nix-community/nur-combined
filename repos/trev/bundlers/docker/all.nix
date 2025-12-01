{
  system,
  pkgs,
  nixpkgs,
}:
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
      let
        drvOverlay = final: prev: {
          "${drv.pname}" = drv;
        };

        crossPkgs = import nixpkgs {
          buildPlatform = system;
          hostPlatform = target.normalized;
          overlays = [
            drvOverlay
          ];
        };
      in
      crossPkgs.callPackage ./default.nix {
        name = "${drv.pname}";
        pkgs = crossPkgs;
      }
    )
  ) targets
)
