{ inputs, ... }:
{
  imports = [
    # https://flake.parts/options/flake-parts-modules.html
    inputs.flake-parts.flakeModules.modules
    inputs.vaultix.flakeModules.default
    inputs.flake-root.flakeModule
  ];
}
