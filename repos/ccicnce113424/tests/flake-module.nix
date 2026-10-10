{
  self,
  ...
}:
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks = {
        # keep-sorted start block=yes newline_separated=yes
        daed = pkgs.testers.runNixOSTest {
          imports = [ ./daed.nix ];
          extraBaseModules = {
            imports = [ self.nixosModules.daed ];
          };
          defaults.services.daed.package = self'.packages.daed;
        };

        honk-core = pkgs.testers.runNixOSTest {
          imports = [ ./honk-core.nix ];
          extraBaseModules = {
            imports = [ self.nixosModules.honk-core ];
          };
          defaults = {
            services.honk-core.package = self'.packages.honk-core;
            services.honk-core.webUi = self'.packages.doona-web;
          };
        };
        # keep-sorted end
      };
    };
}
