{ ... }:
{
  sane.programs.wike = {
    # wike probably meant to put everything here in a subdir, but didn't.
    persist.byStore.cryptClearOnBoot = [
      ".cache/webkitgtk"
      ".local/share/webkitgtk"
    ];
    persist.byStore.private = [
      ".local/share/historic.json"  # history
      # .local/share/cookies (probably not necessary to persist?)

      # .local/share/booklists.json (empty; not sure if wike's)
      # .local/share/bookmarks.json (empty; not sure if wike's)
      # .local/share/languages.json (not sure if wike's)
    ];
  };
}
