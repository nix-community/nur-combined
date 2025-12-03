{
  inputs,
  pkgs,
  lib,
  vaculib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.tf2;
  tf2Pkgs = inputs.tf2-nix.lib.mkTf2Pkgs { inherit pkgs; };
  classes = [
    "scout"
    "soldier"
    "pyro"
    "demoman"
    "heavy"
    "engineer"
    "medic"
    "sniper"
    "spy"
  ];
  mapClassesToAttrs = f: vaculib.mapNamesToAttrs f classes;
  # key: what tf2 calls the key
  # value: other things you might want to call that key
  keyAliases = {
    # from https://developer.valvesoftware.com/wiki/Bind#Special_Keys
    escape = [ "esc" ];
    capslock = [ "caps_lock" ];
    shift = [
      "lshift"
      "left_shift"
    ];
    rshift = [ "right_shfit" ];
    ctrl = [
      "lctrl"
      "control"
      "lcontrol"
      "left_control"
    ];
    rctrl = [
      "rcontrol"
      "right_control"
    ];
    alt = [
      "lalt"
      "left_alt"
    ];
    ralt = [ "right_alt" ];
    space = [ "spacebar" ];
    backspace = [ "bksp" ];
    enter = [ "return" ];
    semicolon = [ ";" ];
    lwin = [
      "win"
      "left_win"
      "meta"
      "lmeta"
      "left_meta"
      "super"
      "lsuper"
      "left_super"
    ];
    rwin = [
      "right_win"
      "rmeta"
      "right_meta"
      "rsuper"
      "right_super"
    ];
    apps = [ "menu" ];
    numlock = [
      "num_lock"
      "number_lock"
    ];
    scrolllock = [
      "scroll_lock"
      "scrlk"
    ];
    uparrow = [ "up" ];
    downarrow = [
      "dn"
      "down"
    ];
    leftarrow = [
      "le"
      "left"
    ];
    rightarrow = [
      "ri"
      "right"
    ];
    ins = [ "insert" ];
    del = [ "delete" ];
    pgdn = [
      "pagedown"
      "page_down"
    ];
    pgup = [
      "pageup"
      "page_up"
    ];
    pause = [
      "pausebreak"
      "pause_break"
      "break"
    ];
    kp_end = [ "kp1" ];
    kp_downarrow = [ "kp2" ];
    kp_pgdn = [ "kp3" ];
    kp_leftarrow = [ "kp4" ];
    kp_5 = [ "kp5" ];
    kp_rightarrow = [ "kp6" ];
    kp_home = [ "kp7" ];
    kp_uparrow = [ "kp8" ];
    kp_pgup = [ "kp9" ];
    kp_enter = [ "kpent" ];
    kp_ins = [
      "kp0"
      "kp_insert"
    ];
    kp_del = [
      "kp."
      "kp_dot"
      "kpdot"
      "kp_decimal"
      "kpdecimal"
      "kp_point"
      "kppoint"
    ];
    kp_slash = [
      "kp/"
      "kp_divide"
      "kpdivide"
    ];
    kp_multiply = [
      "kp*"
      "kp_star"
      "kpstar"
      "kpmultiply"
    ];
    kp_minus = [
      "kp-"
      "kpminus"
      "kp_dash"
      "kpdash"
    ];
    kp_plus = [
      "kp+"
      "kpplus"
    ];
    mwheeldown = [
      "scroll_down"
      "scrolldown"
      "scrolldn"
      "scroll_dn"
    ];
    mwheelup = [
      "scroll_up"
      "scrollup"
    ];
    mouse1 = [
      "left_click"
      "leftclick"
      "primary_click"
      "primaryclick"
    ];
    mouse2 = [
      "right_click"
      "rightclick"
      "secondary_click"
      "secondaryclick"
    ];
    mouse3 = [
      "middle_click"
      "middleclick"
    ];
    mouse4 = [ ];
    mouse5 = [ ];
    #gamepad
    joy1 = [
      "a_button"
      "xbox_a"
      "playstation_x"
      "playstation_cross"
    ];
    joy2 = [
      "b_button"
      "xbox_b"
      "playstation_o"
      "playstation_circle"
    ];
    joy3 = [
      "x_button"
      "xbox_x"
      "playstation_[]"
      "playstation_square"
    ];
    joy4 = [
      "y_button"
      "xbox_y"
      "playstation_^"
      "playstation_triangle"
    ];
    joy5 = [
      "l_shoulder"
      "xbox_left_bumper"
      "xbox_lb"
      "left_bumper"
      "lb"
      "playstation_l1"
      "l1"
    ];
    joy6 = [
      "r_shoulder"
      "xbox_right_bumper"
      "xbox_rb"
      "right_bumper"
      "rb"
      "playstation_r1"
      "r1"
    ];
    joy7 = [
      "back"
      "xbox_back"
      "view"
      "xbox_view"
      "playstation_l2"
      "l2"
    ];
    joy8 = [
      "start"
      "xbox_start"
      "xbox_menu"
      "playstation_r2"
      "r2"
    ];
    joy9 = [
      "stick1"
      "lstick"
      "xbox_lstick"
      "xbox_left_stick"
      "playstation_select"
      "playstation_share"
      "playstation_create"
    ];
    joy10 = [
      "stick2"
      "rstick"
      "xbox_rstick"
      "xbox_right_stick"
      "playstation_start"
      "playstation_options"
    ];
    joy11 = [
      "playstation_l3"
      "l3"
    ];
    joy12 = [
      "playstation_r3"
      "r3"
    ];
    pov_up = [ "dpad_up" ];
    pov_right = [
      "dpad_ri"
      "dpad_right"
    ];
    pov_left = [
      "dpad_le"
      "dpad_left"
    ];
    pov_down = [
      "dpad_dn"
      "dpad_down"
    ];

    # keys named by their character
    "`" = [
      "tilde"
      "~"
      "accent"
      "grave"
      "backtick"
    ];
    "-" = [
      "minus"
      "dash"
    ];
    "=" = [
      "plus"
      "equals"
    ];
    "[" = [
      "left_bracket"
      "le_bracket"
    ];
    "]" = [
      "right_bracket"
      "ri_bracket"
    ];
    "\\" = [
      "backslash"
      "back_slash"
    ];
    # semicolon is above
    "'" = [
      "quote"
      "tick"
      "single_quote"
    ];
    "," = [ "comma" ];
    "." = [
      "dot"
      "period"
    ];
    "/" = [
      "slash"
      "forwardslash"
      "forward_slash"
    ];
  };
  keys =
    (vaculib.listOfLines { } ''
      f1
      f2
      f3
      f4
      f5
      f6
      f7
      f8
      f9
      f10
      f11
      f12
      tab
      home
      end

      1
      2
      3
      4
      5
      6
      7
      8
      9
      0

      q
      w
      e
      r
      t
      y
      u
      i
      o
      p

      a
      s
      d
      f
      g
      h
      j
      k
      l

      z
      x
      c
      v
      b
      n
      m
    '')
    ++ builtins.attrNames keyAliases;
  bindCommandType = types.strMatching ''[a-zA-Z0-9'; +_-]+'';
  bindsModule =
    { config, ... }:
    {
      options =
        (vaculib.mapNamesToAttrsConst (mkOption {
          type = types.nullOr bindCommandType;
          default = null;
        }) keys)
        // {
          _out = mkOption {
            internal = true;
            readOnly = true;
            default = lib.pipe keys [
              (lib.filter (key: config.${key} != null))
              (map (key: ''bind "${key}" "${config.${key}}"''))
              (lib.concatStringsSep "\n")
            ];
          };
        };
      imports = lib.pipe keyAliases [
        (lib.mapAttrsToList (
          key: aliases:
          lib.flip map aliases (
            alias:
            lib.doRename {
              from = [ alias ];
              to = [ key ];
              warn = false;
              use = lib.id;
              visible = true;
              withPriority = true;
            }
          )
        ))
        lib.flatten
      ];
    };
in
{
  _class = null; # this goes in any module system
  options.tf2 = {
    tf2Pkgs = mkOption {
      default = tf2Pkgs;
      defaultText = "`inputs.tf2-nix.lib.mkTf2Pkgs { ... }`";
      readOnly = true;
    };
    binds = {
      clear = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to run unbindall at the beginning of autoexec";
      };
      default = mkOption {
        type = types.submodule bindsModule;
        default = { };
      };
    }
    // vaculib.mapNamesToAttrsConst (mkOption {
      type = types.submodule bindsModule;
      default = { };
    }) classes;
    autoexecLines = mkOption {
      type = types.lines;
      default = "";
    };
    classLines = vaculib.mapNamesToAttrsConst (mkOption {
      type = types.lines;
      default = "";
    }) classes;
    build.autoexec = mkOption {
      type = types.pkg;
      readOnly = true;
    };
    build.classes = vaculib.mapNamesToAttrsConst (mkOption {
      type = types.pkg;
      readOnly = true;
    }) classes;
  };

  config.tf2 = {
    build.autoexec = pkgs.writeFile "autoexec.cfg" cfg.autoexecLines;
    build.classes = mapClassesToAttrs (
      classname: pkgs.writeText "${classname}.cfg" cfg.classLines.${classname}
    );
    autoexecLines = lib.mkMerge (
      [
        ''
          // START keybinds from config.tf2.binds.default
          ${cfg.binds.default._out}
          // END keybinds from config.tf2.binds.default
        ''
      ]
      ++ lib.optional cfg.binds.clear (lib.mkBefore ''unbindall'')
    );
    classLines = mapClassesToAttrs (classname: ''
      // START keybinds from config.tf2.binds.${classname}
      ${cfg.binds.${classname}._out}
      // END keybinds from config.tf2.binds.${classname}
    '');
  };
}
