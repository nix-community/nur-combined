{ pinentryFlavor ? "curses" }:

{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    pinentryFlavor = pinentryFlavor;
  };
}
