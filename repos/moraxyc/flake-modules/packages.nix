{ inputs, ... }:
{
  perSystem =
    {
      system,
      pkgs,
      inputs',
      self',
      config,
      ...
    }:
    let
      inherit (config) nixpkgs-options;
      allNixpkgs = {
        inherit pkgs;
        pkgs-cuda = import inputs.nixpkgs (
          nixpkgs-options
          // {
            config = nixpkgs-options.config // {
              cudaSupport = true;
            };
          }
        );
        pkgs-stable = import inputs.nixpkgs-stable nixpkgs-options;
      };
    in
    {
      packages = import ../pkgs/default.nix {
        inherit inputs' system self';
        inherit (allNixpkgs)
          pkgs
          pkgs-stable
          pkgs-cuda
          ;
      };
    };
}
