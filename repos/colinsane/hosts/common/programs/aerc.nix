# Terminal UI mail client
{ config, sane-lib, ... }:

{
  sane.programs.aerc.secrets.".config/aerc/accounts.conf" = ../../../secrets/universal/aerc_accounts.conf.bin;
}
