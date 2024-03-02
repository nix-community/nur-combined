{ pkgs, ... }:
let
  dmesg = "${pkgs.util-linux}/bin/dmesg";
  grep = "${pkgs.gnugrep}/bin/grep";
  modprobe = "${pkgs.kmod}/bin/modprobe";
  ensureHWReady = ''
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
in
{
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;
  # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-manjaro;
  # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  # alternatively, apply patches directly to stock nixos kernel:
  # boot.kernelPatches = manjaroPatches ++ [
  #   (patchDefconfig kernelConfig)
  # ];

  # configure nixos to build a compressed kernel image, since it doesn't usually do that for aarch64 target.
  # without this i run out of /boot space in < 10 generations
  nixpkgs.hostPlatform.linux-kernel = {
    # defaults:
    name = "aarch64-multiplatform";
    baseConfig = "defconfig";
    DTB = true;
    autoModules = true;
    preferBuiltin = true;
    # extraConfig = ...
    # ^-- raspberry pi stuff: we don't need it.

    # target = "Image";  # <-- default
    target = "Image.gz";  # <-- compress the kernel image
    # target = "zImage";  # <-- confuses other parts of nixos :-(
  };

  # disable proximity sensor.
  # the filtering/calibration is bad that it causes the screen to go fully dark at times.
  boot.blacklistedKernelModules = [ "stk3310" ];

  boot.kernelParams = [
    # without this some GUI apps fail: `DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory`
    # this is because they can't allocate enough video ram.
    # see related nixpkgs issue: <https://github.com/NixOS/nixpkgs/issues/260222>
    # TODO(2023/12/03): remove once mesa 23.3.1 lands: <https://github.com/NixOS/nixpkgs/pull/265740>
    #
    # the default CMA seems to be 32M.
    # i was running fine with 256MB from 2022/07-ish through 2022/12-ish, but then the phone quit reliably coming back from sleep (phosh): maybe a memory leak?
    # `cat /proc/meminfo` to see CmaTotal/CmaFree if interested in tuning this.
    "cma=512M"
    # 2023/10/20: potential fix for the lima (GPU) timeout bugs:
    # - <https://gitlab.com/postmarketOS/pmaports/-/issues/805#note_890467824>
    "lima.sched_timeout_ms=2000"
  ];

  # services.xserver.displayManager.job.preStart = ensureHWReady;
  # systemd.services.greetd.preStart = ensureHWReady;
  systemd.services.unl0kr.preStart = ensureHWReady;
}
