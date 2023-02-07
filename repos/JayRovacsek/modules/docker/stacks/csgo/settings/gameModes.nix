{ user }: {
  inherit (user) uid;
  inherit (user.group) gid;
  name = "csgo-data/csgo/gamemodes_server.txt";
  # Below as per: https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers#Advanced_Configuration
  text = ''
    // Bot Settings
    "bot_quota_mode"     "fill"
    "bot_defer_to_human_items"   "1"
    "bot_defer_to_human_goals"   "0"
    "bot_difficulty"     "1"
    "bot_dont_shoot"     "0"
    "bot_chatter"        "normal"
    "bot_autodifficulty_threshold_low" "-2.0" 
    "bot_autodifficulty_threshold_high"  "0.0"

    // Round Settings
    "mp_afterroundmoney"   "0"
    "mp_playercashawards"    "1"
    "mp_teamcashawards"    "1"
    "mp_maxrounds"     "30"
    "mp_timelimit"     "0"
    "mp_roundtime"     "2"
    "mp_freezetime"      "15"
    "mp_buytime"     "45"
    "mp_forcecamera"   "0"
    "mp_defuser_allocation"    "0"
    "mp_death_drop_gun"    "1"
    "mp_death_drop_grenade"    "2"
    "mp_death_drop_defuser"    "1"
  '';
  mode = "0744";
}
