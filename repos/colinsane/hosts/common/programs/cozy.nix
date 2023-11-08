{ ... }:

{
  sane.programs.cozy = {
    # cozy uses a sqlite db for its config and exposes no CLI options other than --help and --debug
    persist.byStore.plaintext = [
      ".local/share/cozy"  # sqlite db (config & index?)
      ".cache/cozy"  # offline cache
    ];
  };
}
