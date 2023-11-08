{ ... }:
{
  sane.programs.spotify = {
    persist.byStore.plaintext = [
      # probably just songs and such (haven't checked)
      ".cache/spotify"
    ];
    persist.byStore.private = [
      # creds, widevine .so download. TODO: could easily manage these statically.
      ".config/spotify"
    ];
  };
}

