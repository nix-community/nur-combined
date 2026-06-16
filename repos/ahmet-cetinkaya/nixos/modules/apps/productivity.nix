{
  pkgs,
  inputs,
  ...
}: let
  whph = inputs.whph.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    #TODO this will not require in next version
    postFixup =
      (old.postFixup or "")
      + ''
        # KDE launcher expects a matching D-Bus service when DBusActivatable=true.
        # whph does not ship one, so force normal Exec launching.
        sed -i 's/^DBusActivatable=true$/DBusActivatable=false/' \
          "$out/share/applications/me.ahmetcetinkaya.whph.desktop"
      '';
  });
in {
  # Flatpak
  services.flatpak.packages = [
    # Note-taking
    "io.anytype.anytype"
    # Office
    "org.libreoffice.LibreOffice"
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    whph
    obsidian
    affine
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [
    44040 # Allow whph app syncing port
  ];
}
