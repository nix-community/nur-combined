{ ... }:

{
  sane.programs.cozy = {
    sandbox.method = "bwrap";  # landlock gives: _multiprocessing.SemLock: Permission Denied
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.extraHomePaths = [
      "Books"
    ];
    sandbox.extraPaths = [
      "/mnt/servo/media/Books"
    ];
    # cozy uses a sqlite db for its config and exposes no CLI options other than --help and --debug
    persist.byStore.plaintext = [
      ".local/share/cozy"  # sqlite db (config & index?)
      ".cache/cozy"  # offline cache
    ];
  };
}
