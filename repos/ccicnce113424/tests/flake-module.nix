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

        daed-next = pkgs.testers.runNixOSTest {
          imports = [ ./daed-next.nix ];
          extraBaseModules = {
            imports = [ self.nixosModules.daed-next ];
          };
          defaults.services.daed-next.package = self'.packages.daed-next-git;
        };

        gaze = pkgs.testers.runNixOSTest {
          imports = [ ./gaze.nix ];
          extraBaseModules = {
            imports = [ self.nixosModules.gaze ];
          };
          defaults = {
            services.gaze.package = self'.packages.gaze;
            services.gaze.gnome.extensionPackage = self'.packages.gaze-gnome-extension;
            services.gaze.gui.package = self'.packages.gaze-gui;
          };
        };

        honk-core = pkgs.testers.runNixOSTest {
          imports = [ ./honk-core.nix ];
          extraBaseModules = {
            imports = [ self.nixosModules.honk-core ];
          };
          defaults = {
            services.honk-core.package = self'.packages.honk-core;
            services.honk-core.doona.package = self'.packages.doona-web;
          };
        };
        # keep-sorted end
      };
    };
}
