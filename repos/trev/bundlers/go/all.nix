{ pkgs }:
let
  # from https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63
  targets = [
    {
      goos = "windows";
      goarch = "amd64";
      normalized = "x86_64-windows";
    }
    {
      goos = "darwin";
      goarch = "amd64";
      normalized = "x86_64-darwin";
    }
    {
      goos = "darwin";
      goarch = "arm64";
      normalized = "aarch64-darwin";
    }
    {
      goos = "linux";
      goarch = "amd64";
      normalized = "x86_64-linux";
    }
    {
      goos = "linux";
      goarch = "arm";
      normalized = "arm-linux";
    }
    {
      goos = "linux";
      goarch = "arm64";
      normalized = "aarch64-linux";
    }
  ];
in
builtins.listToAttrs (
  map (
    target:
    pkgs.lib.attrsets.nameValuePair "go-${target.normalized}" (
      drv:
      import ./. {
        inherit drv;
        goos = target.goos;
        goarch = target.goarch;
        normalized = target.normalized;
      }
    )
  ) targets
  ++ map (
    target:
    pkgs.lib.attrsets.nameValuePair "go-compress-${target.normalized}" (
      drv:
      import ./compress.nix {
        inherit drv;
        goos = target.goos;
        goarch = target.goarch;
        normalized = target.normalized;
      }
    )
  ) targets
)
