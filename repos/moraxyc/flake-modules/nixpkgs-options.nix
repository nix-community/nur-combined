{ inputs, ... }:
{
  perSystem =
    {
      system,
      config,
      lib,
      ...
    }:
    let
      pkgs-options = {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "olm-3.2.16" # mautrix-telegramgo

            "quickjs-2025-09-13-2" # subconverter
          ];
        };
        overlays = [
          (final: prev: {
            local = config.packages;
            upstream = prev;
          })
        ];
      };
    in
    {
      options.nixpkgs-options = lib.mkOption {
        type = lib.types.anything;
        default = { };
      };
      config = {
        _module.args.pkgs = import inputs.nixpkgs pkgs-options;
        nixpkgs-options = pkgs-options;
      };
    };
}
