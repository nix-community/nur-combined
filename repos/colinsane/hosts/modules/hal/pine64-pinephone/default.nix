{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.pine64-pinephone;
in
{
  options = {
    sane.hal.pine64-pinephone.enable = lib.mkEnableOption "pinephone-specific hardware support (NOT pinephone pro!)";
  };

  imports = [
    ./kernel.nix
  ];

  config = lib.mkIf cfg.enable {
    # disable proximity sensor.
    # the filtering/calibration is bad that it causes the screen to go fully dark at times.
    # boot.blacklistedKernelModules = [ "stk3310" ];

    boot.blacklistedKernelModules = [
      # XXX: gc2145_mipi must be blacklisted for the camera (front *or* rear) to function.
      # the others are related (they did not appear when running megi's kernel, but now do),
      # but apparently OK
      "gc2145_mipi"  #< only present in megi's patches. gc2145_mipi is actually the *mainline* gc2145 driver
      # "gc2145"  #< this could be the mainline, or megi's, driver, based on compilation flags. disable both for now.
      # "leds_group_multicolor"
      # "pinctrl_axp209"
      # "led_class_multicolor"
      # "v4l2_cci"
    ];

    boot.extraModprobeConfig = ''
      # 2024-09-01: disable power-saving if using the rtw88 rtl8723cs WiFi driver
      # power saving was observed to cause frequent disconnections and reconnections
      # on mainline 6.10.7 and mainline 6.11.0-rc5.
      # recommendation to disable lps was seen here:
      # - <https://bbs.archlinux.org/viewtopic.php?id=273440>
      #
      # without this, `dmesg --follow` shows recurring events like:
      # [   68.406648] wlan0: authenticate with xx:xx:xx:xx:xx:xx (local address=xx:xx:xx:xx:xx:xx)
      # [   68.502376] wlan0: send auth to xx:xx:xx:xx:xx:xx (try 1/3)
      # [   68.516573] wlan0: authenticated
      # [   68.522666] wlan0: associate with xx:xx:xx:xx:xx:xx (try 1/3)
      # [   68.541704] wlan0: RX AssocResp from xx:xx:xx:xx:xx:xx (capab=0x14xx status=0 aid=5)
      # [   68.554838] wlan0: associated
      #
      # [  176.505711] wlan0: authenticate with xx:xx:xx:xx:xx:xx (local address=02:ba:7a:03:b4:a6)
      # [  176.608752] wlan0: send auth to xx:xx:xx:xx:xx:xx (try 1/3)
      # [  176.620025] wlan0: authenticated
      # [  176.654670] wlan0: associate with xx:xx:xx:xx:xx:xx (try 1/3)
      # [  176.690814] wlan0: RX AssocResp from xx:xx:xx:xx:xx:xx (capab=0x14xx status=0 aid=5)
      # [  176.743676] wlan0: associated
      #
      # N.B.: this doesn't solve *all* de-association issues, but i'm fairly (?) confident it reduces them
      #
      options rtw88_core disable_lps_deep=y
    '';

    boot.kernelParams = [
      # without this some GUI apps fail: `DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory`
      # this is because they can't allocate enough video ram.
      # see related nixpkgs issue: <https://github.com/NixOS/nixpkgs/issues/260222>
      #
      # the default CMA seems to be 32M.
      # i was running fine with 256MB from 2022/07-ish through 2022/12-ish, but then the phone quit reliably coming back from sleep (phosh): maybe a memory leak?
      # bumped to 512M on 2023/01
      # bumped to 1536M on 2024/05
      # `cat /proc/meminfo` to see CmaTotal/CmaFree if interested in tuning this.
      # kernel param mentioned here: <https://cateee.net/lkddb/web-lkddb/CMA_SIZE_PERCENTAGE.html> (or CONFIG_CMA_SIZE_MBYTES)
      # cli arguments described more here: <https://lwn.net/Articles/396707/>
      # i think cma mem isn't exclusive -- it can be used as ordinary `malloc`, still. i heard someone suggest the OS default should just be 50% memory to CMA.
      # on the other hand the postmarketOS folk seek to remove their usages of CMA altogether: <https://gitlab.com/postmarketOS/pmaports/-/merge_requests/5541#note_2082937081>
      # in fact, setting this to `cma=0M` still results in a bootable, graphical environment (as of 2024-09-11).
      # "cma=256M"
      # "cma=1536M"
      # "cma=0M"
      # 2023/10/20: potential fix for the lima (GPU) timeout bugs:
      # - <https://gitlab.com/postmarketOS/pmaports/-/issues/805#note_890467824>
      "lima.sched_timeout_ms=2000"
    ];

    # defined: https://www.freedesktop.org/software/systemd/man/machine-info.html
    # XXX colin: disabled until/unless it's actually needed.
    # environment.etc."machine-info".text = ''
    #   CHASSIS="handset"
    # '';

    # hardware.firmware makes the referenced files visible to the kernel, for whenever a driver explicitly asks for them.
    # these files are visible from userspace by following `/sys/module/firmware_class/parameters/path`
    #
    # mobile-nixos' /lib/firmware includes:
    #   rtl_bt          (bluetooth)
    #   anx7688-fw.bin  (USB-C chip: power negotiation, HDMI/dock)
    #   ov5640_af.bin   (camera module)
    # hardware.firmware = [ pkgs.rtl8723cs-firmware ];
    hardware.firmware = [
      (pkgs.linux-firmware-megous.override {
        # rtl_bt = false probably means no bluetooth connectivity.
        # N.B.: DON'T RE-ENABLE without first confirming that wake-on-lan works during suspend (rtcwake).
        # it seems the rtl_bt stuff ("bluetooth coexist") might make wake-on-LAN radically more flaky.
        rtl_bt = false;
      })
    ];

    # docs (pinephone specific; tow-boot instead of u-boot but close enough): <https://github.com/Tow-Boot/Tow-Boot/tree/development/boards/pine64-pinephoneA64>
    # we need space in the GPT header to place u-boot.
    # only actually need 1 MB, but better to over-allocate than under-allocate
    sane.image.extraGPTPadding = 16 * 1024 * 1024 - 34 * 512;
    sane.image.firstPartGap = 0;
    sane.image.installBootloader = ''
      dd if=${pkgs.u-boot-pinephone}/u-boot-sunxi-with-spl.bin of=$out bs=1024 seek=8 conv=notrunc
    '';

    sane.programs.alsa-ucm-conf.suggestedPrograms = [
      "pine64-alsa-ucm"  # upstreaming: <https://github.com/alsa-project/alsa-ucm-conf/issues/399>
    ];

    sane.programs.nwg-panel.config.torch = "white:flash";
    sane.programs.swaynotificationcenter.config = {
      backlight = "backlight";  # /sys/class/backlight/*backlight*/brightness
    };

    services.udev.extraRules = let
      chmod = lib.getExe' pkgs.coreutils "chmod";
      chown = lib.getExe' pkgs.coreutils "chown";
    in ''
      # make Pinephone flashlight writable by user.
      # taken from postmarketOS: <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/60-flashlight.rules>
      SUBSYSTEM=="leds", DEVPATH=="*/*:flash", RUN+="${chmod} g+w /sys%p/brightness /sys%p/flash_strobe", RUN+="${chown} :video /sys%p/brightness /sys%p/flash_strobe"

      # make Pinephone front LEDs writable by user.
      SUBSYSTEM=="leds", DEVPATH=="*/*:indicator", RUN+="${chmod} g+w /sys%p/brightness", RUN+="${chown} :video /sys%p/brightness"
    '';

    systemd.services.unl0kr.preStart = let
      dmesg = lib.getExe' pkgs.util-linux "dmesg";
      grep = lib.getExe pkgs.gnugrep;
      modprobe = lib.getExe' pkgs.kmod "modprobe";
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
      # NB: this is the most common, but not the only, failure mode for `display-manager`.
      # another error seems characterized by these dmesg logs, in which reprobing sun8i_drm_hdmi does not fix:
      # ```syslog
      # sun6i-mipi-dsi 1ca0000.dsi: Couldn't get the MIPI D-PHY
      # sun4i-drm display-engine: Couldn't bind all pipelines components
      # sun6i-mipi-dsi 1ca0000.dsi: Couldn't register our component
      # ```

      if (${dmesg} --kernel --level err --color=never --notime | ${grep} -q 'sun4i-drm display-engine: failed to bind 1ee0000.hdmi')
      then
        echo "reprobing sun8i_drm_hdmi"
        # if a command here fails it errors the whole service, so prefer to log instead
        ${modprobe} -r sun8i_drm_hdmi || echo "failed to unload sun8i_drm_hdmi"
        ${modprobe} sun8i_drm_hdmi || echo "failed to load sub8i_drm_hdmi"
      fi
    '';
  };
}

