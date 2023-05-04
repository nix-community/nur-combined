# mail archiving/synchronization tool.
#
# manually download all emails for an account with
# - `offlineimap -a <accountname>`
#
# view account names inside the secrets file, listed below.
{ ... }:

{
  sane.programs.offlineimap.secrets.".config/offlineimap/config" = ../../../secrets/universal/offlineimaprc.bin;
}

