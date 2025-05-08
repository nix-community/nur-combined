{ inputs, ... }:
{
  perSystem =
    {
      system,
      inputs',
      lib,
      ...
    }:
    let
      pkgs-options = {
        inherit system;
        config = {
          allowUnfree = true;
          # permittedInsecurePackages = [
          # ];
        };
        # overlays = [
        # ] ++ (import ../overlays { inherit inputs inputs'; });
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
