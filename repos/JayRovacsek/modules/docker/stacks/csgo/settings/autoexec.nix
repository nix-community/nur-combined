{ user }: {
  name = "csgo-data/csgo/cfg/autoexec.cfg";
  # Below as per: https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Advanced_Configuration
  text = ''
    log on
    hostname "Counter-Strike: noob healthy funs!"
    rcon_password ""
    sv_password ""
    sv_cheats 0
    sv_lan 0
    exec banned_user.cfg
    exec banned_ip.cfg
  '';
  inherit (user) uid;
  gid = user.group.id;
  mode = "0744";
}
