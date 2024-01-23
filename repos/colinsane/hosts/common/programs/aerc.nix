# Terminal UI mail client
{ ... }:

{
  sane.programs.aerc = {
    sandbox.method = "bwrap";
    secrets.".config/aerc/accounts.conf" = ../../../secrets/common/aerc_accounts.conf.bin;
    mime.associations."x-scheme-handler/mailto" = "aerc.desktop";
  };
}
