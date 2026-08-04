{ lib, ... }:

let
  identity = import ../library/identity.lib.nix { inherit lib; };
in
{
  accounts.email.accounts.${identity.email} = rec {
    realName = identity.name.long;
    address = identity.email;
    flavor = "fastmail.com";
    passwordCommand = "gopass show --password andrew_kvalheim/fastmail/${address}/msmtp";

    primary = true;
    msmtp = {
      enable = true;
      extraConfig.from_full_name = realName; # TODO: Upstream
    };
  };

  programs.msmtp.enable = true;
}
