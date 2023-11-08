{ config, pkgs, sane-lib, ... }:

let
  init-keyring = pkgs.static-nix-shell.mkBash {
    pname = "init-keyring";
    src = ./.;
  };
in
{
  sane.user.persist.byStore.private = [ ".local/share/keyrings" ];

  sane.user.fs."private/.local/share/keyrings/default" = {
    generated.command = [ "${init-keyring}/bin/init-keyring" ];
    wantedBy = [ config.sane.fs."/home/colin/private".unit ];
    wantedBeforeBy = [ ];  # don't created this as part of `multi-user.target`
  };
}
