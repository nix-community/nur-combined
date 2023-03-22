{ self, inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    packages =
      let
        inherit (inputs.futils.lib) filterPackages flattenTree;
        packages = import "${self}/pkgs" { inherit pkgs; };
        flattenedPackages = flattenTree packages;
        finalPackages = filterPackages system flattenedPackages;
      in
      finalPackages;
  };
}
