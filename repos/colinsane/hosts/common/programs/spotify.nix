{ ... }:
{
  sane.programs.spotify = {
    persist.plaintext = [
      # probably just songs and such (haven't checked)
      ".cache/spotify"
    ];
    persist.private = [
      # creds, widevine .so download. TODO: could easily manage these statically.
      ".config/spotify"
    ];
  };
}

