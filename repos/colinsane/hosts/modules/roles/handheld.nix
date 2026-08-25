{ config, lib, ... }:
{
  options.sane.roles.handheld = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      services/programs which you probably only want on a handheld device.
    '';
  };

  config = lib.mkIf config.sane.roles.handheld {
    # expose a ssh-capable network to the USB port.
    # connect another computer to this handheld, and then ssh in like:
    # ```
    #   ip link  # to determine the interface, e.g. `usb0`
    #   sudo ip addr add 172.16.42.2/24 dev <interface>
    #   sudo ip link set <interface> up
    #   ssh 172.16.42.1
    # ```
    boot.kernelModules = [ "libcomposite" "usb_f_ncm" ];
    systemd.services.usb-gadget = {
      unitConfig.DefaultDependencies = false;
      requires = [ "sys-kernel-config.mount" ];
      after = [ "systemd-modules-load.service" "sys-kernel-config.mount" ];
      wantedBy = [ "basic.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      # TODO: how much of this can be removed/simplified? unsure if it's device-specific or not.
      script = ''
        gadget=/sys/kernel/config/usb_gadget/g1
        mkdir -p "$gadget"
        echo 0x1d6b > "$gadget/idVendor"
        echo 0x0104 > "$gadget/idProduct"
        mkdir -p "$gadget/strings/0x409"
        echo Xiaomi > "$gadget/strings/0x409/manufacturer"
        echo "NixOS handheld" > "$gadget/strings/0x409/product"
        echo NixOS > "$gadget/strings/0x409/serialnumber"
        mkdir -p "$gadget/functions/ncm.usb0"
        mkdir -p "$gadget/configs/c.1/strings/0x409"
        echo "USB network" > "$gadget/configs/c.1/strings/0x409/configuration"
        ln -s "$gadget/functions/ncm.usb0" "$gadget/configs/c.1/"
        echo "$(ls /sys/class/udc | head -1)" > "$gadget/UDC"
      '';
    };
    networking.firewall.trustedInterfaces = [ "usb0" ];
    systemd.network.networks."usb0" = {
      matchConfig.Name = "usb0";
      address = [ "172.16.42.1/24" ];
      networkConfig.ConfigureWithoutCarrier = true;
      linkConfig.RequiredForOnline = false;
    };

    sane.programs.guiApps.suggestedPrograms = [
      "consoleMediaUtils"  # overbroad, but handy on very rare occasion
      "handheldGuiApps"
    ];
    sane.programs.geoclue2.suggestedPrograms = [
      "gps-share"
    ];
    sane.programs.sway.suggestedPrograms = [
      "sane-input-handler"
    ];

    sane.programs.alacritty.config.fontSize = 9;
    # XXX(2026-06-17): wezterm doesn't support touch scrolling; alacritty does
    sane.programs.xdg-terminal-exec.config.terminal = "alacritty";

    sane.programs.firefox.config = {
      # compromise impermanence for the sake of usability
      persistCache = "private";
      persistData = "private";

      # i don't do crypto stuff on moby
      addons.ether-metamask.enable = false;
      # sidebery UX doesn't make sense on small screen
      addons.sidebery.enable = false;
    };
    sane.programs.firefox.mime.priority = 300;  # prefer other browsers when possible

    sane.programs.sway.config = {
      font = "pango:monospace 10";
      locker = "schlock";
      mod = "Mod1";  # prefer Alt
      workspace_layout = "tabbed";
    };

    sane.programs.swayidle.config = {
      actions.screenoff.delay = 300;
      actions.screenoff.enable = true;
    };
    sane.programs.swaynotificationcenter.config = {
      enableMpris = false;  #< consumes too much screen real-estate
    };

    sane.programs.waybar.config = {
      fontSize = 14;
      height = 26;
      persistWorkspaces = [ "1" "2" "3" "4" "5" ];
      modules.media = false;
      modules.network = false;
      modules.perf = false;
      modules.windowTitle = false;
      # TODO: show modem state
    };
    sane.programs.nwg-panel.config = {
      fontSize = 14;
      height = 26;
      windowIcon = false;
      windowTitle = false;
      mediaPrevNext = false;
      mediaTitle = false;
      sysload = false;
      workspaceNumbers = [ "1" "2" "3" "4" "5" ];
      workspaceHideEmpty = false;
    };

    sane.programs.sane-deadlines.config.showOnLogin = false;  # unlikely to act on them when in shell
  };
}

