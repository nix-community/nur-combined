# Pinephone
# other setups to reference:
# - <https://hamblingreen.gitlab.io/2022/03/02/my-pinephone-setup.html>
#   - sxmo Arch user. lots of app recommendations
#
# wikis, resources, ...:
# - Linux Phone Apps: <https://linuxphoneapps.org/>
#   - massive mobile-friendly app database
# - Mobian wiki: <https://wiki.mobian-project.org/doku.php?id=start>
#   - recommended apps, chatrooms

{ config, pkgs, lib, ... }:
{
  imports = [
    ./bootloader.nix
    ./fs.nix
    ./gps.nix
    ./kernel.nix
    ./polyfill.nix
  ];

  sane.roles.client = true;
  sane.roles.handheld = true;
  sane.zsh.showDeadlines = false;  # unlikely to act on them when in shell
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."moby".wg-home.ip;

  # for some reason desko -> moby deploys are super flaky when desko is also a nixcache (not true of desko -> lappy deploys, though!)
  # > unable to download 'http://desko:5001/<hash>.narinfo': Server returned nothing (no headers, no data) (52)
  sane.nixcache.substituters.desko = false;

  # XXX colin: phosh doesn't work well with passwordless login,
  # so set this more reliable default password should anything go wrong
  users.users.colin.initialPassword = "147147";
  # services.getty.autologinUser = "root";  # allows for emergency maintenance?

  sops.secrets.colin-passwd.neededForUsers = true;

  # sane.gui.sxmo.enable = true;
  sane.programs.sway.enableFor.user.colin = true;
  sane.programs.swaylock.enableFor.user.colin = false;  #< not usable on touch
  sane.programs.schlock.enableFor.user.colin = true;
  sane.programs.swayidle.config.actions.screenoff.delay = 300;
  sane.programs.swayidle.config.actions.screenoff.enable = true;
  sane.programs.sane-input-handler.enableFor.user.colin = true;
  sane.programs.blueberry.enableFor.user.colin = false;  # bluetooth manager: doesn't cross compile!
  sane.programs.fcitx5.enableFor.user.colin = false;  # does not cross compile
  sane.programs.mercurial.enableFor.user.colin = false;  # does not cross compile
  sane.programs.nvme-cli.enableFor.system = false;  # does not cross compile (libhugetlbfs)

  # enabled for easier debugging
  sane.programs.eg25-control.enableFor.user.colin = true;
  sane.programs.rtl8723cs-wowlan.enableFor.user.colin = true;

  # sane.programs.ntfy-sh.config.autostart = true;
  sane.programs.dino.config.autostart = true;
  # sane.programs.signal-desktop.config.autostart = true;  # TODO: enable once electron stops derping.
  # sane.programs."gnome.geary".config.autostart = true;
  # sane.programs.calls.config.autostart = true;

  sane.programs.firefox.mime.priority = 300;  # prefer other browsers when possible
  # HACK/TODO: make `programs.P.env.VAR` behave according to `mime.priority`
  sane.programs.firefox.env = lib.mkForce {};
  sane.programs.epiphany.env.BROWSER = "epiphany";

  # note the .conf.d approach: using ~/.config/pipewire/pipewire.conf directly breaks all audio,
  # presumably because that deletes the defaults entirely whereas the .conf.d approach selectively overrides defaults
  sane.user.fs.".config/pipewire/pipewire.conf.d/10-fix-dino-mic-cutout.conf".symlink.text = ''
    # config docs: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Config-PipeWire#properties>
    # useful to run `pw-top` to see that these settings are actually having effect,
    # and `pw-metadata` to see if any settings conflict (e.g. max-quantum < min-quantum)
    #
    # restart pipewire after editing these files:
    # - `systemctl --user restart pipewire`
    # - pipewire users will likely stop outputting audio until they are also restarted
    #
    # there's seemingly two buffers for the mic (see: <https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/FAQ#pipewire-buffering-explained>)
    # 1. Pipewire buffering out of the driver and into its own member.
    # 2. Pipewire buffering into Dino.
    # the latter is fixed at 10ms by Dino, difficult to override via runtime config.
    # the former defaults low (e.g. 512 samples)
    # this default configuration causes the mic to regularly drop out entirely for a couple seconds at a time during a call,
    # presumably because the system can't keep up (pw-top shows incrementing counter in ERR column).
    # `pw-metadata -n settings 0 clock.force-quantum 1024` reduces to about 1 error per second.
    # `pw-metadata -n settings 0 clock.force-quantum 2048` reduces to 1 error every < 10s.
    # pipewire default config includes `clock.power-of-two-quantum = true`
    context.properties = {
      default.clock.min-quantum = 2048
      default.clock.max-quantum = 8192
    }
  '';

  boot.loader.efi.canTouchEfiVariables = false;
  # /boot space is at a premium. default was 20.
  # even 10 can be too much
  boot.loader.generic-extlinux-compatible.configurationLimit = 8;
  # mobile.bootloader.enable = false;
  # mobile.boot.stage-1.enable = false;
  # boot.initrd.systemd.enable = false;
  # boot.initrd.services.swraid.enable = false;  # attempt to fix dm_mod stuff

  # hardware.firmware makes the referenced files visible to the kernel, for whenever a driver explicitly asks for them.
  # these files are visible from userspace by following `/sys/module/firmware_class/parameters/path`
  #
  # mobile-nixos' /lib/firmware includes:
  #   rtl_bt          (bluetooth)
  #   anx7688-fw.bin  (USB-C chip: power negotiation, HDMI/dock)
  #   ov5640_af.bin   (camera module)
  # hardware.firmware = [ config.mobile.device.firmware ];
  # hardware.firmware = [ pkgs.rtl8723cs-firmware ];
  hardware.firmware = [
    (pkgs.linux-firmware-megous.override {
      # rtl_bt = false probably means no bluetooth connectivity.
      # N.B.: DON'T RE-ENABLE without first confirming that wake-on-lan works during suspend (rtcwake).
      # it seems the rtl_bt stuff ("bluetooth coexist") might make wake-on-LAN radically more flaky.
      rtl_bt = false;
    })
  ];

  system.stateVersion = "21.11";

  # defined: https://www.freedesktop.org/software/systemd/man/machine-info.html
  # XXX colin: not sure which, if any, software makes use of this
  environment.etc."machine-info".text = ''
    CHASSIS="handset"
  '';

  # enable rotation sensor
  hardware.sensor.iio.enable = true;

  # TODO: move elsewhere...
  systemd.services.ModemManager.serviceConfig = {
    # N.B.: the extra "" in ExecStart serves to force upstream ExecStart to be ignored
    ExecStart = [ "" "${pkgs.modemmanager}/bin/ModemManager --debug" ];
    # --debug sets DEBUG level logging: so reset
    ExecStartPost = [ "${pkgs.modemmanager}/bin/mmcli --set-logging=INFO" ];
  };

  services.udev.extraRules = let
    chmod = "${pkgs.coreutils}/bin/chmod";
    chown = "${pkgs.coreutils}/bin/chown";
  in ''
    # make Pinephone flashlight writable by user.
    # taken from postmarketOS: <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/60-flashlight.rules>
    SUBSYSTEM=="leds", DEVPATH=="*/*:flash", RUN+="${chmod} g+w /sys%p/brightness /sys%p/flash_strobe", RUN+="${chown} :video /sys%p/brightness /sys%p/flash_strobe"

    # make Pinephone front LEDs writable by user.
    SUBSYSTEM=="leds", DEVPATH=="*/*:indicator", RUN+="${chmod} g+w /sys%p/brightness", RUN+="${chown} :video /sys%p/brightness"
  '';
}
