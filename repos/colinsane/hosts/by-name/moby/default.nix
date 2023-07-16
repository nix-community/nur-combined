# Pinephone
# other setups to reference:
# - <https://hamblingreen.gitlab.io/2022/03/02/my-pinephone-setup.html>
#   - sxmo Arch user. lots of app recommendations

{ config, pkgs, lib, ... }:
{
  imports = [
    ./firmware.nix
    ./fs.nix
    ./kernel.nix
    ./polyfill.nix
  ];

  sane.roles.client = true;
  sane.zsh.showDeadlines = false;  # unlikely to act on them when in shell
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."moby".wg-home.ip;

  # XXX colin: phosh doesn't work well with passwordless login,
  # so set this more reliable default password should anything go wrong
  users.users.colin.initialPassword = "147147";
  services.getty.autologinUser = "root";  # allows for emergency maintenance?

  sops.secrets.colin-passwd.neededForUsers = true;

  sane.user.persist.plaintext = [
    # TODO: make this just generally conditional upon pulse being enabled?
    ".config/pulse"  # persist pulseaudio volume
  ];

  sane.gui.sxmo.enable = true;
  sane.programs.guiApps.suggestedPrograms = [ "handheldGuiApps" ];
  # sane.programs.consoleUtils.enableFor.user.colin = false;
  # sane.programs.guiApps.enableFor.user.colin = false;
  sane.programs.sequoia.enableFor.user.colin = false;
  sane.programs.tuiApps.enableFor.user.colin = false;  # visidata, others, don't compile well
  # disabled for faster deploys
  sane.programs.soundconverter.enableFor.user.colin = false;
  sane.programs.firefox.enableFor.user.colin = false;  # use epiphany instead
  # sane.programs.mpv.enableFor.user.colin = true;

  boot.loader.efi.canTouchEfiVariables = false;
  # /boot space is at a premium. default was 20.
  # even 10 can be too much
  boot.loader.generic-extlinux-compatible.configurationLimit = 8;
  # mobile.bootloader.enable = false;
  # mobile.boot.stage-1.enable = false;
  # boot.initrd.systemd.enable = false;
  # boot.initrd.services.swraid.enable = false;  # attempt to fix dm_mod stuff
  # disable proximity sensor.
  # the filtering/calibration is bad that it causes the screen to go fully dark at times.
  boot.blacklistedKernelModules = [ "stk3310" ];

  # without this some GUI apps fail: `DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory`
  # this is because they can't allocate enough video ram.
  # the default CMA seems to be 32M.
  # i was running fine with 256MB from 2022/07-ish through 2022/12-ish, but then the phone quit reliably coming back from sleep: maybe a memory leak?
  # `cat /proc/meminfo` to see CmaTotal/CmaFree if interested in tuning this.
  boot.kernelParams = [ "cma=512M" ];

  # mobile-nixos' /lib/firmware includes:
  #   rtl_bt          (bluetooth)
  #   anx7688-fw.bin  (USB-C -> HDMI bridge)
  #   ov5640_af.bin   (camera module)
  # hardware.firmware = [ config.mobile.device.firmware ];
  hardware.firmware = [ pkgs.rtl8723cs-firmware ];

  system.stateVersion = "21.11";

  # defined: https://www.freedesktop.org/software/systemd/man/machine-info.html
  # XXX colin: not sure which, if any, software makes use of this
  environment.etc."machine-info".text = ''
    CHASSIS="handset"
  '';

  # enable rotation sensor
  hardware.sensor.iio.enable = true;

  # inject specialized alsa configs via the environment.
  # specifically, this gets the pinephone headphones & internal earpiece working.
  # see pkgs/patched/alsa-ucm-conf for more info.
  environment.variables.ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";
  environment.pathsToLink = [ "/share/alsa/ucm2" ];
  environment.systemPackages = [ pkgs.alsa-ucm-conf-sane ];
  systemd =
    let ucm-env = config.environment.variables.ALSA_CONFIG_UCM2;
    in {
    # cribbed from <repo:nixos/mobile-nixos:modules/quirks/audio.nix>

    # pulseaudio
    user.services.pulseaudio.environment.ALSA_CONFIG_UCM2 = ucm-env;
    services.pulseaudio.environment.ALSA_CONFIG_UCM2      = ucm-env;

    # pipewire
    user.services.pipewire.environment.ALSA_CONFIG_UCM2       = ucm-env;
    user.services.pipewire-pulse.environment.ALSA_CONFIG_UCM2 = ucm-env;
    user.services.wireplumber.environment.ALSA_CONFIG_UCM2    = ucm-env;
    services.pipewire.environment.ALSA_CONFIG_UCM2            = ucm-env;
    services.pipewire-pulse.environment.ALSA_CONFIG_UCM2      = ucm-env;
    services.wireplumber.environment.ALSA_CONFIG_UCM2         = ucm-env;
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

  hardware.opengl.driSupport = true;

  services.xserver.displayManager.job.preStart = let
    dmesg = "${pkgs.util-linux}/bin/dmesg";
    grep = "${pkgs.gnugrep}/bin/grep";
    modprobe = "${pkgs.kmod}/bin/modprobe";
  in ''
    # common boot failure:
    # blank screen (no backlight even), with the following log:
    # ```syslog
    # sun8i-dw-hdmi 1ee0000.hdmi: Couldn't get the HDMI PHY
    # ...
    # sun4i-drm display-engine: Couldn't bind all pipelines components
    # ...
    # sun8i-dw-hdmi: probe of 1ee0000.hdmi failed with error -17
    # ```
    #
    # in particular, that `probe ... failed` occurs *only* on failed boots
    # (the other messages might sometimes occur even on successful runs?)
    #
    # reloading the sun8i hdmi driver usually gets the screen on, showing boot text.
    # then restarting display-manager.service gets us to the login.
    #
    # NB: the above log is default level. though less specific, there's a `err` level message that also signals this:
    # sun4i-drm display-engine: failed to bind 1ee0000.hdmi (ops sun8i_dw_hdmi_ops [sun8i_drm_hdmi]): -17

    if (${dmesg} --kernel --level err --color=never --notime | ${grep} -q 'sun4i-drm display-engine: failed to bind 1ee0000.hdmi')
    then
      echo "reprobing sun8i_drm_hdmi"
      # if a command here fails it errors the whole service, so prefer to log instead
      ${modprobe} -r sun8i_drm_hdmi || echo "failed to unload sun8i_drm_hdmi"
      ${modprobe} sun8i_drm_hdmi || echo "failed to load sub8i_drm_hdmi"
    fi
  '';
}
