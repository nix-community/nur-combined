# Example for customizing instantwm packages.
# Copy to repo root and install with:
#     nix-env -iA instantnix -f customization.nix

(import ./.. { pkgs=import <nixpkgs> {}; }).extend (self: super: {
  instantwm = (super.instantwm.override {
    wmconfig = ./customconfig.h;
    extraPatches = [ ./../pkgs/instantWm/mouseoverlay.patch ];
  });
  instantutils = (super.instantutils.override {
    extraPatches = [ ./dateformat.patch ];
  });
})
