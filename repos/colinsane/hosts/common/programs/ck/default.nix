{ ... }:
{
  sane.programs.ck = {
    sandbox.whitelistPwd = true;
    sandbox.net = "clearnet";  # for model downloads
    persist.byStore.private = [
      ".cache/ck"
    ];
  };
}
