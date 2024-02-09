{ ... }:
{
  sane.programs.xdg-utils = {
    sandbox.method = "capshonly";
    sandbox.wrapperType = "wrappedDerivation";
    # xdg-utils portal interaction: for `xdg-open` to open a file whose handler may require files not in the current sandbox,
    # we have to use a background service. that's achieved via `xdg-desktop-portal` and the org.freedesktop.portal.OpenURI dbus interface.
    # so, this `xdg-open` should simply forward all requests to the portal, and the portal may re-invoke xdg-open without that redirection.
    #
    # note that `xdg-desktop-portal` seems to (inadvertently) only accept requests from applications which *don't* have elevated privileges, hence xdg-open *has* to be sandboxed for this to work.
    env.NIXOS_XDG_OPEN_USE_PORTAL = "1";
  };

  # ensure that any `xdg-open` invocations from within the portal don't recurse.
  # N.B.: use `systemd.user.units...` instead of `systemd.user.services...` because the latter
  # pollutes the PATH for this unit.
  systemd.user.units."xdg-desktop-portal.service".text = ''
    [Service]
    Environment="NIXOS_XDG_OPEN_USE_PORTAL="
  '';
}
