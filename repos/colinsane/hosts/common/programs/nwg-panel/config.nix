# TODO:
# - try this PR to get custom workspace names to work:
#   - <https://github.com/nwg-piotr/nwg-panel/pull/191>
# - add network/bluetooth indicator
#   - <https://github.com/nwg-piotr/nwg-panel/issues/269>
# - add CPU/meminfo executor
#   - use sane-sysload
{
  controlsSettingsComponents,
  controlsSettingsCustomItems,
  height,
  locker,
  modulesRight,
  playerctlChars,
  mediaPrevNext,
  windowIcon,
  windowTitle,
  workspaceHideEmpty,
  workspaceNumbers,
}:
[
  {
    controls = "right";
    css-name = "panel-top";
    exclusive-zone = true;
    height = height;
    homogeneous = false;  #< homogenous=false means to not force modules-{left,center,right} to an inflexible 33%/33%/33% real-estate split.
    icons = "light";
    items-padding = 0;
    layer = "bottom";
    margin-bottom = 0;
    margin-top = 0;
    menu-start = "off";
    name = "panel-top";
    # output = "All" => display the bar on every output.
    # - documented: <https://github.com/nwg-piotr/nwg-panel/issues/48>
    # alternatively, i could declare one bar per display,
    # and then customize it so that the external display(s) render a less noisy bar.
    # this will be easier once this is addressed: <https://github.com/nwg-piotr/nwg-panel/issues/215>
    output = "All";
    padding-horizontal = 0;
    padding-vertical = 0;
    position = "top";
    sigrt = 64;
    spacing = 0;
    start-hidden = false;
    use-sigrt = false;
    width = "auto";

    modules-left = [
      "sway-workspaces"
    ];
    modules-center = [
      "clock"
    ];
    modules-right = modulesRight;

    clock = {
      angle = 0.0;
      calendar-css-name = "calendar-window";
      calendar-icon-size = 24;
      calendar-interval = 60;
      calendar-margin-horizontal = 0;
      calendar-margin-vertical = 0;
      calendar-on = true;
      calendar-path = "";
      calendar-placement = "top";
      css-name = "clock";
      format = "%H:%M";
      interval = 30;
      on-left-click = "";
      on-middle-click = "";
      on-right-click = "";
      on-scroll-down = "";
      on-scroll-up = "";
      root-css-name = "root-clock";
      tooltip-date-format = true;
      tooltip-text = "%a; %d %b  %H:%M:%S";
    };
    controls-settings = {
      battery-low-interval = 4;  #< notify every N minutes when battery continues to remain low
      battery-low-level = 15;  #< notify if battery is lower than this percent
      # commands.battery = "";  #< optional action to perform when battery icon is clicked in the drop-down menu
      components = controlsSettingsComponents;
      click-closes = false;
      custom-items = controlsSettingsCustomItems;
      css-name = "controls-window";
      hover-opens = false;
      icon-size = 16;
      interval = 60;  #< volume/brightness refresh. when dropdown is revealed, this is forced to 500ms.
      leave-closes = false;
      menu.icon = "system-shutdown-symbolic";
      menu.items = [
        {
          name = "Lock";
          cmd = "systemctl start ${locker}";
        }
        # {
        #   name = "Logout";
        #   cmd = "swaymsg exit";
        # }
        {
          name = "Reboot";
          cmd = "reboot";
        }
        {
          name = "Shutdown";
          cmd = "shutdown now";
        }
      ];
      menu.name = "Exit";
      output-switcher = true;  #< allow changing the default audio sink
      #v `show-<x>` means "show the NUMERICAL VALUE corresponding to <x>"
      #  e.g. show-battery means "show the battery _percentage_ next to its icon".
      show-battery = true;
      show-brightness = false;
      show-values = false;
      show-volume = false;
      # window-width: should be 360 for moby, but because of weird `margin` tweaks in style.css
      # we have to add 20px to both sides
      window-width = 400;
    };
    playerctl = {
      button-css-name = "playerctl-button";
      buttons-position = "left";
      chars = playerctlChars;
      icon-size = 16;
      interval = 2;
      label-css-name = "playerctl-label";
      scroll = false;
      show-cover = false;  #< don't show the little music-note icon
      show-previous = mediaPrevNext;
      show-next = mediaPrevNext;
      show-name = mediaPrevNext;
    };
    swaync = {
      css-name = "swaync-label";
      # interval = 1;
      # icon-placement = "left";
      # icon-size = 18;
      # tooltip-text = "";
      # on-left-click = "swaync-client -t";
      # on-right-click = "";
      # on-middle-click = "";
      # on-scroll-up = "";
      # on-scroll-down = "";
      # always-show-icon = true;
    };
    sway-workspaces = {
      angle = 0.0;
      custom-labels = [];
      focused-labels = [];
      hide-empty = workspaceHideEmpty;
      image-size = 16;
      mark-autotiling = true;
      mark-content = false;
      name-length = 40;
      numbers = workspaceNumbers;
      show-icon = windowIcon;
      show-layout = false;
      show-name = windowTitle;
    };

    executor-sysload = {
      script = "sane-sysload {mem} {cpu}";
      interval = 10;
      css-name = "";
      on-right-click = "";
      icon-size = 16;
      show-icon = false;
      tooltip-text = "";
      on-left-click = "";
      on-middle-click = "";
      on-scroll-up = "";
      on-scroll-down = "";
    };

    # unused modules:
    brightness-slider = {};
    dwl-tags = {};
    hyprland-taskbar = {};
    hyprland-workspaces = {};
    keyboard-layout = {};
    openweather = {};
    scratchpad = {};
    sway-mode = {};
    sway-taskbar = {}; #< windows-style taskbar, usually placed at the bottom of the screen, to show open windows & tab to them on click
    tray = {};
  }
]

