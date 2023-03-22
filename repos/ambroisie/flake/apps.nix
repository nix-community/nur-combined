{ inputs, ... }:
{
  perSystem = { self', ... }: {
    apps = {
      diff-flake = inputs.futils.lib.mkApp { drv = self'.packages.diff-flake; };
      default = self'.apps.diff-flake;
    };
  };
}
