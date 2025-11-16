{ pkgs, lib, ... }:
let

  # genDeps = n: lib.genAttrs n (name: lib.getExe pkgs.${name});

  # wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  # wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
  pw-volume = "${pkgs.pw-volume}/bin/pw-volume";

  # deps = genDeps [
  #   "fuzzel"
  #   "foot"
  #   "grim"
  #   "light"
  #   "playerctl"
  #   "pulsemixer"
  #   "slurp"
  #   "swaybg"
  #   "swaylock"
  #   "hyprpicker"
  #   "cliphist"
  #   "firefox"
  #   "tdesktop"
  #   "save-clipboard-to"
  #   "screen-recorder-toggle"
  #   "systemd-run-app"
  # ];

  execApp = lib.concatMapStringsSep " " (i: ''"${i}"'');
  execDesktop =
    app:
    execApp [
      "niri"
      "msg"
      "action"
      "spawn"
      "--"
      app
    ];
in
# kdl
''
  input {
      keyboard {
          xkb {
              // You can set rules, model, layout, variant and options.
              // For more information, see xkeyboard-config(7).

              // For example:
              // layout "us,ru"
              // options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"
          }

          // You can set the keyboard repeat parameters. The defaults match wlroots and sway.
          // Delay is in milliseconds before the repeat starts. Rate is in characters per second.
          // repeat-delay 600
          // repeat-rate 25

          // Niri can remember the keyboard layout globally (the default) or per-window.
          // - "global" - layout change is global for all windows.
          // - "window" - layout is tracked for each window individually.
          // track-layout "global"
      }

      // Next sections include libinput settings.
      // Omitting settings disables them, or leaves them at their default values.
      touchpad {
          tap
          // dwt
          natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
          // tap-button-map "left-middle-right"
      }

      mouse {
          // natural-scroll
          // accel-speed 0.2
          // accel-profile "flat"
      }

      tablet {
          // Set the name of the output (see below) which the tablet will map to.
          // If this is unset or the output doesn't exist, the tablet maps to one of the
          // existing outputs.
          map-to-output "eDP-1"
      }


      // By default, niri will take over the power button to make it sleep
      // instead of power off.
      // Uncomment this if you would like to configure the power button elsewhere
      // (i.e. logind.conf).
      // disable-power-key-handling
  }

  environment {
  }
  xwayland-satellite {
      path "${lib.getExe pkgs.xwayland-satellite}"
  }

  workspace "term"
  workspace "surf"
  workspace "chat"
  workspace "mail"

  window-rule {
      match app-id="Alacritty"
      match app-id="foot"
      match app-id="rio"
      match is-active=true
      match is-focused=true
      open-maximized true
      // opacity 0.92
  }

  window-rule {
      match at-startup=true app-id=r#"^foot$"#
      match at-startup=true app-id=r#"^rio$"#
      open-on-workspace "term"
  }
  window-rule {
      match at-startup=true app-id=r#"^firefox$"#
      match at-startup=true app-id=r#"^google-chrome"#
      match at-startup=true app-id=r#"^chromium-browser"#
      open-on-workspace "surf"
  }

  window-rule {
      match at-startup=true app-id=r#"^org\.telegram\.desktop$"#
      open-maximized true
      open-on-workspace "chat"
  }

  window-rule {
      match at-startup=true app-id=r#"^thunderbird$"#
      open-on-workspace "mail"
  }

  window-rule {
      match title="Firefox"
      match app-id=r#"^google-chrome"#
      match app-id=r#"^chromium-browser"#
      match app-id="thunderbird"
      open-maximized true
  }

  output "eDP-1" {
   // off

   // Scale is a floating-point number, but at the moment only integer values work.
   scale 2.0

   mode "2160x1440@60.001"

   // position x=1080 y=0
  }

  output "PNP(GKT) Kuycon P24U Unknown" {
   // off

   scale 2.0

   mode "3840x2160@60.000"
  }

  output "Samsung Electric Company S24R35x H4TM706141" {
      // off
      mode "1920x1080@60"
      scale 1.5
  }

  layout {
      // You can change how the focus ring looks.
      focus-ring {
          // Uncomment this line to disable the focus ring.
          // off

          // How many logical pixels the ring extends out from the windows.
          width 2

          active-color "#B28FCE"
          inactive-color "#585b70"
      }

      // You can also add a border. It's similar to the focus ring, but always visible.
      border {
          // The settings are the same as for the focus ring.
          // If you enable the border, you probably want to disable the focus ring.
          off

          width 1
          active-color 240 201 207 255
          inactive-color 80 80 80 255
      }

      // You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
      preset-column-widths {
          // Proportion sets the width as a fraction of the output width, taking gaps into account.
          // For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
          // The default preset widths are 1/3, 1/2 and 2/3 of the output.
          proportion 0.33333
          proportion 0.5
          proportion 0.66667

          // Fixed sets the width in logical pixels exactly.
          // fixed 1920
      }

      // You can change the default width of the new windows.
      default-column-width { proportion 0.5; }
      // If you leave the brackets empty, the windows themselves will decide their initial width.
      // default-column-width {}

      // Set gaps around windows in logical pixels.
      gaps 6

      // Struts shrink the area occupied by windows, similarly to layer-shell panels.
      // You can think of them as a kind of outer gaps. They are set in logical pixels.
      // Left and right struts will cause the next window to the side to always be visible.
      // Top and bottom struts will simply add outer gaps in addition to the area occupied by
      // layer-shell panels and regular gaps.
      struts {
          // left 64
          // right 64
          // top 64
          // bottom 64
      }

      // When to center a column when changing focus, options are:
      // - "never", default behavior, focusing an off-screen column will keep at the left
      //   or right edge of the screen.
      // - "on-overflow", focusing a column will center it if it doesn't fit
      //   together with the previously focused column.
      // - "always", the focused column will always be centered.
      center-focused-column "never"

      tab-indicator {
          // off
          hide-when-single-tab
          place-within-column
          gap 5
          width 4
          length total-proportion=1.0
          gaps-between-tabs 2
          corner-radius 8
          // active-gradient from="#80c8ff" to="#bbddff" angle=45
          // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
      }
  }

  // Add lines like this to spawn processes at startup.
  // Note that running niri as a session supports xdg-desktop-autostart,
  // which may be more convenient to use.
  spawn-at-startup ${execApp [ (lib.getExe pkgs.foot) ]}
  spawn-at-startup ${execDesktop "chromium-browser"}
  spawn-at-startup ${execDesktop "Telegram"}
  spawn-at-startup ${execDesktop "thunderbird"}
  spawn-sh-at-startup "vicinae server"
  cursor {
      // Change the theme and size of the cursor as well as set the
      // `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
      xcursor-theme "Bibata-Modern-Ice"
      xcursor-size 24
  }

  // Uncomment this line to ask the clients to omit their client-side decorations if possible.
  // If the client will specifically ask for CSD, the request will be honored.
  // Additionally, clients will be informed that they are tiled, removing some rounded corners.
  prefer-no-csd

  // You can change the path where screenshots are saved.
  // A ~ at the front will be expanded to the home directory.
  // The path is formatted with strftime(3) to give you the screenshot date and time.
  screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

  // You can also set this to null to disable saving screenshots to disk.
  // screenshot-path null

  // Settings for the "Important Hotkeys" overlay.
  hotkey-overlay {
      // Uncomment this line if you don't want to see the hotkey help at niri startup.
      skip-at-startup
  }

  // Use a custom build of xwayland-satellite.
  binds {
      // Keys consist of modifiers separated by + signs, followed by an XKB key name
      // in the end. To find an XKB name for a particular key, you may use a program
      // like wev.
      //
      // "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
      // when running as a winit window.

      // Mod-Shift-/, which is usually the same as Mod-?,
      // shows a list of important hotkeys.
      Mod+Shift+Slash { show-hotkey-overlay; }

      // Suggested binds for running programs: terminal, app launcher, screen locker.
      Mod+Return { spawn ${execApp [ (lib.getExe pkgs.foot) ]}; }
      Mod+D repeat=false { spawn "vicinae" "toggle"; }
      Ctrl+Shift+L { spawn "loginctl" "lock-session"; }
      Mod+W { toggle-column-tabbed-display; }
      Mod+T { toggle-overview; }
      Mod+P { spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle"; }
      


      Mod+WheelScrollDown cooldown-ms=150 { focus-column-right; }
      Mod+WheelScrollUp   cooldown-ms=150 { focus-column-left; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { focus-workspace-up; }
      // Mod+WheelScrollRight                { focus-column-right; }
      // Mod+WheelScrollLeft                 { focus-column-left; }

      XF86AudioMute allow-when-locked=true { spawn "sh" "-c" "${pw-volume} mute toggle; pkill -RTMIN+8 waybar"; }

      // Example volume keys mappings for PipeWire & WirePlumber.
      XF86AudioRaiseVolume { spawn "sh" "-c" "${pw-volume} change +1%; pkill -RTMIN+8 waybar"; }
      XF86AudioLowerVolume { spawn "sh" "-c" "${pw-volume} change -1%; pkill -RTMIN+8 waybar"; }

      XF86MonBrightnessUp { spawn "light" "-A" "3"; }
      XF86MonBrightnessdown { spawn "light" "-U" "3"; }
      Mod+Ctrl+P repeat=false { spawn "vicinae" "vicinae://extensions/vicinae/clipboard/history"; }

      Mod+Q { close-window; }

      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+L     { focus-column-right; }

      Mod+Ctrl+Left  { move-column-left; }
      Mod+Ctrl+Down  { move-window-down; }
      Mod+Ctrl+Up    { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+H     { move-column-left; }
      Mod+Ctrl+L     { move-column-right; }

      // Alternative commands that move across workspaces when reaching
      // the first or last window in a column.
      Mod+J     { focus-window-or-workspace-down; }
      Mod+K     { focus-window-or-workspace-up; }
      Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
      Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

      Mod+Home { focus-column-first; }
      Mod+End  { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End  { move-column-to-last; }

      Mod+Shift+Left  { focus-monitor-left; }
      Mod+Shift+Down  { focus-monitor-down; }
      Mod+Shift+Up    { focus-monitor-up; }
      Mod+Shift+Right { focus-monitor-right; }
      Mod+Shift+H     { focus-monitor-left; }
      Mod+Shift+J     { focus-monitor-down; }
      Mod+Shift+K     { focus-monitor-up; }
      Mod+Shift+L     { focus-monitor-right; }

      Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
      Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

      // Alternatively, there are commands to move just a single window:
      // Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
      // ...

      Mod+Page_Down      { focus-workspace-down; }
      Mod+Page_Up        { focus-workspace-up; }
      Mod+U              { focus-workspace-down; }
      Mod+I              { focus-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
      Mod+Ctrl+U         { move-column-to-workspace-down; }
      Mod+Ctrl+I         { move-column-to-workspace-up; }

      // Alternatively, there are commands to move just a single window:
      // Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
      // ...

      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up   { move-workspace-up; }
      Mod+Shift+U         { move-workspace-down; }
      Mod+Shift+I         { move-workspace-up; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      // Alternatively, there are commands to move just a single window:
      // Mod+Ctrl+1 { move-window-to-workspace 1; }

      Mod+Comma  { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }

      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }

      // Finer width adjustments.
      // This command can also:
      // * set width in pixels: "1000"
      // * adjust width in pixels: "-5" or "+5"
      // * set width as a percentage of screen width: "25%"
      // * adjust width as a percentage of screen width: "-10%" or "+10%"
      // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
      // set-column-width "100" will make the column occupy 200 physical screen pixels.
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

      // Finer height adjustments when in column with other windows.
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // Actions to switch layouts.
      // Note: if you uncomment these, make sure you do NOT have
      // a matching layout switch hotkey configured in xkb options above.
      // Having both at once on the same hotkey will break the switching,
      // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
      // Mod+Space       { switch-layout "next"; }
      // Mod+Shift+Space { switch-layout "prev"; }

      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }

      Mod+Shift+Ctrl+T { toggle-debug-tint; }
  }

  // Settings for debugging. Not meant for normal use.
  // These can change or stop working at any point with little notice.
  debug {
      // Make niri take over its DBus services even if it's not running as a session.
      // Useful for testing screen recording changes without having to relogin.
      // The main niri instance will *not* currently take back the services; so you will
      // need to relogin in the end.
      // dbus-interfaces-in-non-session-instances

      // Wait until every frame is done rendering before handing it over to DRM.
      // wait-for-frame-completion-before-queueing

      // Enable direct scanout into overlay planes.
      // May cause frame drops during some animations on some hardware.
      // enable-overlay-planes

      // Disable the use of the cursor plane.
      // The cursor will be rendered together with the rest of the frame.
      // disable-cursor-plane

      // Slow down animations by this factor.
      // animation-slowdown 3.0

      // Override the DRM device that niri will use for all rendering.
      // render-drm-device "/dev/dri/renderD129"
      keep-max-bpc-unchanged
  }
''
