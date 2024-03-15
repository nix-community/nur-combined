{
  self,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, system, ... }:
    {
      # This sets `pkgs` to a nixpkgs with allowUnfree option set.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-11.5.0"
            "electron-19.1.9"
            "openssl-1.1.1w"
            "python-2.7.18.7"
          ];
        };
      };

      packages.default = pkgs.hello-unfree;
    };
}
