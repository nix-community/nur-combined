{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pipewire-bluez5-lhdc;

  # Register the LHDC v5 capable bluez5 SPA plugins with WirePlumber, the way
  # the AUR `wireplumber-lhdc-config` package does:
  #
  #   [Service]
  #   Environment=SPA_PLUGIN_DIR=<lhdc plugins>:/usr/lib/spa-0.2
  #
  # The order matters: PipeWire walks the `:`-separated SPA_PLUGIN_DIR and uses
  # the first `bluez5/libspa-bluez5.so` it finds, and that library resolves its
  # codec plugins (`bluez5/libspa-codec-bluez5-*.so`, LHDC v5 included) through
  # the same list, so this package's bluez5 plugins have to come first and stay
  # together.
  #
  # WirePlumber is the process that loads them: it enumerates Bluetooth devices
  # in its own context (`SpaDevice("api.bluez5.enum.dbus")`) and creates their
  # nodes with `LocalNode("adapter")`, i.e. through PipeWire's client-node
  # module, so the PipeWire daemon keeps using its own bluez5 plugins.
  spaPluginDir = lib.concatStringsSep ":" [
    "${cfg.package}/lib/spa-0.2"
    "${config.services.pipewire.package}/lib/spa-0.2"
  ];
in
{
  options.services.pipewire-bluez5-lhdc = {
    enable = lib.mkEnableOption "LHDC v5 support in PipeWire's Bluetooth (bluez5) SPA plugins";

    package = lib.mkPackageOption pkgs "pipewire-bluez5-lhdc-git" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.wireplumber.environment.SPA_PLUGIN_DIR =
      lib.mkIf config.services.pipewire.systemWide spaPluginDir;

    systemd.user.services.wireplumber.environment.SPA_PLUGIN_DIR = lib.mkIf (
      !config.services.pipewire.systemWide
    ) spaPluginDir;
  };

  meta.maintainers = with lib.maintainers; [ ccicnce113424 ];
}
