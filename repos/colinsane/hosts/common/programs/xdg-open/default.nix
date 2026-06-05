{ ... }:
{
  sane.programs.xdg-open = {
    sandbox.autodetectCliPaths = "existing";
    # sandbox.whitelistDbus.user.all = true;  #< uncomment if xdg-dbus-proxy doesn't support nesting
    sandbox.whitelistPortal = [
      "OpenURI"
    ];

    # env.NIXOS_XDG_OPEN_USE_PORTAL = "1";  #< required for `xdg-utils`; but for `flatpak-xdg-utils` this is default
  };
}
