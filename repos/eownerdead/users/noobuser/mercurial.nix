{ config, ... }:
let
  email = config.accounts.email.accounts."eownerdead@disroot.org";
in
{
  programs.mercurial = {
    enable = true;
    userEmail = email.address;
    userName = email.realName;
  };
}
