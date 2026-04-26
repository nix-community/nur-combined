{
  self,
  ...
}:
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks.daed = pkgs.testers.runNixOSTest {
        imports = [ ./daed.nix ];
        extraBaseModules = {
          imports = [ self.nixosModules.daed ];
        };
        defaults.services.daed.package = self'.packages.daed;
      };
    };
}
