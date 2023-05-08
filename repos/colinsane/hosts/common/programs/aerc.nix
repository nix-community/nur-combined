# Terminal UI mail client
{ ... }:

{
  sane.programs.aerc.secrets.".config/aerc/accounts.conf" = ../../../secrets/universal/aerc_accounts.conf.bin;
}
