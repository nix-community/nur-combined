{ ... }:
{
  # N.B.: prefer to use wl-clipboard-rs where possible, to avoid the dependency on `xdg-mime`
  # as that fails to cross compile frequently due to its dependency on perl.
  #
  # wl-clipboard-rs is a near drop-in replacement.
  sane.programs.wl-clipboard = {
    sandbox.whitelistWayland = true;
    sandbox.keepPids = true;  #< this is needed, but not sure why?
    suggestedPrograms = [
      "xdg-mime"
    ];
  };
}
