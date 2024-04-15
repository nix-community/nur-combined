# https://nix.dev/tutorials/module-system/module-system.html
## https://github.com/tweag/summer-of-nix-modules
{
  description = "Wrapping the world in modules";

  outputs = {
    self,
    nixpkgs,
  }: {
    packages.x86_64-linux.module = nixpkgs.lib.evalModules {
      modules = [
        ({config, ...}: {config._module.args = {pkgs = nixpkgs.x86_64-linux.legacyPackages;};})
        ./default.nix
      ];
    };
  };
}
