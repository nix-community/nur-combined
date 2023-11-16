{ pkgs, ... }:
{
  sane.programs.signal-desktop = {
    package = pkgs.signal-desktop-from-src;
    # creds, media
    persist.byStore.private = [
      ".config/Signal"
    ];
  };
}
