{ ... }:
{
  sane.programs.gnome-frog = {
    buildCost = 1;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus.user.own = [
      "com.github.tenderowl.frog"
    ];
    sandbox.whitelistPortal = [
      "Screenshot"
    ];
    sandbox.extraPaths = [
      # needed when processing screenshots (TODO: can i have it use a custom TMPDIR?)
      "/tmp"
    ];
    sandbox.extraHomePaths = [
      # for OCR'ing photos from disk
      "tmp"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
    ];
    persist.byStore.ephemeral = [
      ".local/share/tessdata"  # 15M; dunno what all it is.
    ];
    sandbox.mesaCacheDir = ".cache/gnome-frog/mesa";  # TODO: is this the correct app-id?
  };
}
