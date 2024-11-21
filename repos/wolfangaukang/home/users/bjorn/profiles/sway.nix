{ pkgs
, lib
, config
, osConfig
, inputs
, hostname
, localLib
, ...
}:

let
  inherit (pkgs) waybar;
  inherit (localLib) getHostDefaults;
  hostInfo = getHostDefaults hostname;
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" { inherit pkgs config lib; };
  mainMod = "Mod4";

in
{
  imports = [ ./wayland.nix ];
  programs.waybar.package = waybar.override {
    pipewireSupport = true;
    swaySupport = config.wayland.windowManager.sway.enable;
    traySupport = true;
  };
  wayland.windowManager.sway = {
    enable = osConfig.programs.sway.enable;
    checkConfig = false;
    config = {
      modifier = mainMod;
      terminal = commands.terminal;
      defaultWorkspace = "workspace number 1";
      menu = commands.menu;
      bars = [{
        command = lib.getExe waybar;
      }];
      gaps = {
        inner = 10;
        smartGaps = true;
        smartBorders = "on";
      };
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in {
        "Ctrl+Alt+Delete" = "exec ${commands.powerMenu}";
        #"${modifier}+Ctrl+Alt+Delete" = "exit"
        "${modifier}+Space" = "exec ${commands.menu}";
        "${modifier}+t" = "exec ${commands.terminal}";
        "${modifier}+l" = "exec --no-startup-id ${commands.lock}";
        "${modifier}+s" = "exec ${commands.systemdMenu}";
        "${modifier}+b" = "exec ${commands.bluetoothMgmt}";
        "${modifier}+k" = "exec ${commands.calc}";
        "${modifier}+g" = "exec ${commands.top}";
        "Print" = "exec --no-startup-id --no-startup-id ${commands.screenshot "save" "screen"}";
        "Alt+Print" = "exec --no-startup-id ${commands.screenshot "save" "window"}";
        "Shift+Print" = "exec --no-startup-id ${commands.screenshot "save" "area"}";
        "Ctrl+Print" = "exec --no-startup-id ${commands.screenshot "copy" "screen"}";
        "Ctrl+Alt+Print" = "exec --no-startup-id ${commands.screenshot "copy" "window"}";
        "Ctrl+Shift+Print" = "exec --no-startup-id ${commands.screenshot "copy" "area"}";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${commands.volume} -d 5";
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${commands.volume} -i 5";
        "XF86AudioMute" = "exec --no-startup-id ${commands.volumeMute}";

        ## Tiles
        #"ALT, Tab, cyclenext"
        #"SHIFTALT, Tab, cyclenext, prev"
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Alt+Up" = "move up";
        "${modifier}+Alt+Down" = "move down";
        "${modifier}+Alt+Left" = "move left";
        "${modifier}+Alt+Right" = "move right";
        "${modifier}+f" = "floating toggle";
        "${modifier}+q" = "kill";
        # Splitting
        "${modifier}+h" = "splith";
        "${modifier}+v" = "splitv";
        # Layout mode
        "${modifier}+Alt+l" = "layout stacking";
        "${modifier}+Alt+u" = "layout tabbed";
        "${modifier}+Alt+y" = "layout toggle split";
        #"${modifier}, U, togglefloating"

        ## Workspace
        "${modifier}+Ctrl+1" = "workspace number 1";
        "${modifier}+Ctrl+2" = "workspace number 2";
        "${modifier}+Ctrl+3" = "workspace number 3";
        "${modifier}+Ctrl+4" = "workspace number 4";
        "${modifier}+Ctrl+5" = "workspace number 5";
        "${modifier}+Ctrl+6" = "workspace number 6";
        "${modifier}+Ctrl+7" = "workspace number 7";
        "${modifier}+Ctrl+8" = "workspace number 8";
        "${modifier}+Ctrl+9" = "workspace number 9";
        "${modifier}+Ctrl+0" = "workspace number 10";
        "${modifier}+Ctrl+left" = "workspace prev";
        "${modifier}+Ctrl+right" = "workspace next";

        ## Move tile to another workspace
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+left" = "move container to workspace prev";
        "${modifier}+Shift+right" = "move container to workspace next";

        ## TODO: Consider
        # https://www.reddit.com/r/hyprland/comments/xaujb9/a_couple_questions_about_hyprland/
        #"${mainMod}, P, pseudo, # dwindle"
        #"${mainMod}, J, togglesplit, # dwindle"

        ## Scroll workspace bind
        #"${mainMod} SHIFT, mouse_down, workspace, e+1"
        #"${mainMod} SHIFT, mouse_up, workspace, e-1"

        # ... Special workspace binds?
        # https://www.reddit.com/r/hyprland/comments/18nt7qg/special_workspace_usage/
        #"${mainMod}, S, togglespecialworkspace, magic"
        #"${mainMod} SHIFT, S, movetoworkspace, special:magic"
      #];
      };
      output = let mainDisplay = hostInfo.display.id;
        in { "${mainDisplay}".bg = "${config.home.homeDirectory}/.wallpaper.jpg fill"; };
      window.titlebar = false;
    };
    extraConfig = ''
      for_window [title="Choose a Firefox profile"] floating enable
      for_window [title="Picture-in-Picture"] floating enable
    '';
    wrapperFeatures.gtk = true;
    xwayland = true;
    #settings = {
      #env = [
        #"XCURSOR_SIZE,24"
        #"QT_QPA_PLATFORMTHEME,qt5ct # change to qt6ct if you have that"
        #"GTK_THEME,Nord"
      #];
      #input = {
        #follow_mouse = 1;
        #sensitivity = 0;
      #};
      #general = {
        #gaps_in = 5;
        #gaps_out = 20;
        #border_size = 2;
        #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        #"col.inactive_border" = "rgba(595959aa)";
      #};
      #decoration = {
        #rounding = 10;
        #blur = {
          #enabled = true;
          #size = 3;
          #passes = 1;
          #vibrancy = 0.1696;
        #};
        #drop_shadow = true;
        #shadow_range = 4;
        #shadow_render_power = 3;
        #"col.shadow" = "rgba(1a1a1aee)";
      #};
      #animations = {
        #enabled = true;
        #bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        #animation = [
          #"windows, 1, 7, myBezier"
          #"windowsOut, 1, 7, default, popin 80%"
          #"border, 1, 10, default"
          #"borderangle, 1, 8, default"
          #"fade, 1, 7, default"
        #];
      #};
      #dwindle = {
        #pseudotile = true;
        #preserve_split = true;
      #};
      #master.new_is_master = true;
      #device = {
        #name = "epic-mouse-v1";
        #sensitivity = -0.5;
      #};
      #windowrulev2 = [
        #"suppressevent maximize, class:.*"
      #];
   #};
  };
}
