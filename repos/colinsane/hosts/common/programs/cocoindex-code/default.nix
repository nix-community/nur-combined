{ ... }:
{
  sane.programs.cocoindex-code = {
    sandbox.whitelistPwd = true;
    sandbox.net = "clearnet";  # for model downloads
    persist.byStore.private = [
      ".cocoindex_code"
    ];
  };
}
