{ ... }:
{
  sane.programs.auto-zoekt = {
    sandbox.whitelistPwd = true;
    persist.byStore.private = [
      ".cache/zoekt"
    ];

    sandbox.extraHomePaths = [
      # zoekt needs to locate the repo state dir to know where to put its cache dir.
      # like git itself, that means crawling *up* the path -- which isn't necessarily in the
      # sandbox otherwise -- to locate parent .git files. So I kinda have to just add all the common dirs.
      "dev"
      "knowledge"
      "nixos"
      "ref"
    ];
  };
}
