{ ... }:
{
  sane.programs.brave = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";  # /opt/share/brave.com vendor-style packaging
    sandbox.net = "all";
    sandbox.extraHomePaths = [
      "dev"  # for developing anything web-related
      "tmp"
    ];
    sandbox.whitelistDri = true;
    persist.byStore.cryptClearOnBoot = [
      ".cache/BraveSoftware"
      ".config/BraveSoftware"
    ];
  };
}
