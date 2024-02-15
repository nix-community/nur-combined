{ ... }:

{
  sane.programs.cozy = {
    sandbox.method = "bwrap";  # landlock gives: _multiprocessing.SemLock: Permission Denied
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # mpris
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Books"
      "Books/servo"
    ];

    # cozy uses a sqlite db for its config and exposes no CLI options other than --help and --debug
    persist.byStore.plaintext = [
      ".local/share/cozy"  # sqlite db (config & index?)
      ".cache/cozy"  # offline cache
    ];
  };
}
