{ config, sane-lib, ... }:

{
  sane.user.persist.private = [ ".local/share/keyrings" ];

  sane.user.fs."private/.local/share/keyrings/default" = {
    generated.script.script = builtins.readFile ../../../scripts/init-keyring;
    # TODO: is this `wantedBy` needed? can we inherit it?
    wantedBy = [ config.sane.fs."/home/colin/private".unit ];
  };
}
