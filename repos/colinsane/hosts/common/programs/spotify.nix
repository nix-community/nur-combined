{ ... }:
{
  sane.programs.spotify = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # nontraditional package structure, where binaries live in /share/spotify
    sandbox.net = "clearnet";
    sandbox.extraConfig = [
      "--sane-sandbox-firejail-arg"
      "--keep-dev-shm"
    ];
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

