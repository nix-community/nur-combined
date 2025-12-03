{ vacuModules, ... }:
{
  imports = [ vacuModules.tf2 ];

  tf2.binds.clear = true;
  tf2.binds.default = {
    "2" = "voicemenu 1 1"; # call spy

    w = "+forward";
    a = "+moveleft";
    s = "+back";
    d = "+moveright";
    "'" = "+moveup";
    "/" = "+movedown";
    space = "+jump";
    shift = "+duck";
    alt = "+strafe";

    mouse1 = "+attack";
    mouse2 = "+attack2";

    q = "slot1";
    f = "slot2";
    mouse4 = "slot3";
    "3" = "slot3";
    "4" = "slot4";
    "5" = "slot5";
    scroll_up = "invprev";
    scroll_dn = "invnext";

    z = "voice_menu_1";
    x = "voice_menu_2";
    c = "voice_menu_3";

    g = "+taunt";
    h = "reload";
    j = "cl_trigger_first_notification";
    k = "kill";
    l = "explode";
    ";" = "cl_decline_first_notification";
    tab = "+showscores";
    esc = "cancelselect";

    m = "open_charinfo_direct";
    n = "open_charinfo_backpack";
    o = "dropitem";

    r = "+helpme";
    v = "+voicerecord";
    p = "say_party";
    y = "say_team";
    t = "say";

    kp0 = "load_itempreset 0";
    kp1 = "load_itempreset 1";
    kp2 = "load_itempreset 2";
    kp3 = "load_itempreset 3";

    "`" = "toggleconsole";
    "," = "changeclass";
    "." = "changeteam";

    backslash = "show_matchmaking";
    f1 = "+showroundinfo";
    f2 = "show_quest_log";
    f3 = "askconnect_accept";
    f5 = "screenshot";
    f6 = "save_replay";
    f7 = "abuse_report_queue";
    f9 = "vr_toggle";
    f10 = "quit prompt";
    f11 = "vr_reset_home_pos";
    f12 = "replay_togglereplaytips";
  };
  tf2.binds.engineer = {
    "4" = "destroy 1 0; build 1 0"; # build teleporter entrance
    "5" = "destroy 1 1; build 1 1"; # build teleporter exit
  };
  tf2.binds.spy = {
    "-" = "disguiseteam";
  };
}
