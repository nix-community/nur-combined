# Terminal UI mail client
{ pkgs, ... }:

{
  sane.programs.aerc = {
    packageUnwrapped = pkgs.aerc.override {
      withNotmuch = false;  #< not used; regularly fails to build
    };
    sandbox.wrapperType = "inplace";  #< /share/aerc/aerc.conf mentions (in comments) other (non-sandboxed) /share files by absolute path
    sandbox.net = "clearnet";
    sandbox.extraHomePaths = [
      "tmp"  # for adding and saving attachments
    ];

    secrets.".config/aerc/accounts.conf" = ../../../../secrets/common/aerc_accounts.conf.bin;
    mime.associations."x-scheme-handler/mailto" = "aerc.desktop";
  };
}
