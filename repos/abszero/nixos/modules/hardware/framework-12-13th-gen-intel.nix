{
  options,
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkDefault optionalAttrs;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.framework-12-13th-gen-intel;

  keyboardCfg = {
    devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
    extraDefCfg = ''
      danger-enable-cmd yes
      process-unmapped-keys yes
      log-layer-changes no
    '';
    config = ''
      (defsrc
        esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  del
        `    1    2    3    4    5    6    7    8    9    0    -    =    bspc
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        caps a    s    d    f    g    h    j    k    l    ;    '         ret
        lsft z    x    c    v    b    n    m    ,    .    /              rsft
        lctl lmet lalt           spc            ralt rctl left down up   rght)

      (deflayer canary
        @>q  _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    +    _
        _    w    l    y    p    k    z    x    o    u    ;    _    _    _
        @esc c    r    s    t    b    f    n    e    i    a    _         _
        @ls  j    v    d    g    q    m    h    /    ,    .              @rs
        _    _    _              _              _    _    _    _    _    _)

      (deflayer qwerty
        @>c  _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    +    _
        _    q    w    e    r    t    y    u    i    o    p    _    _    _
        @esc a    s    d    f    g    h    j    k    l    ;    _         _
        @ls  z    x    c    v    b    n    m    ,    .    /              @rs
        _    _    _              _              _    _    _    _    _    _)

      (deflayer shift
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    @=   _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _
        _    _    _    _    _    _    _    _    _    _    _              _
        _    _    _              _              _    _    _    _    _    _)

      (deflayer lower
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    left down up   rght _         _
        _    _    _    _    _    _    _    home pgdn pgup end            _
        _    _    _              _              _    _    _    _    _    _)

      (defalias
        >q (tap-dance 150 (caps (layer-switch qwerty)))
        >c (tap-dance 150 (caps (layer-switch canary)))
        esc (tap-hold-press 150 150 esc (layer-while-held lower))
        ls (multi lsft (layer-while-held shift))
        rs (multi rsft (layer-while-held shift))
        =  (unshift =))
    '';
  };
in

{
  imports = [
    ../../../lib/modules/config/abszero.nix
    ../services/hardware/kanata.nix
  ];

  options.abszero.hardware.framework-12-13th-gen-intel.enable = mkExternalEnableOption config ''
    Framework laptop 12 13th gen Intel configuration complementary to
    `inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel`. Due to the nixos-hardware
    module being effective on import, it's not imported by this module; you have to import them
    yourself
  '';

  config = mkIf cfg.enable {
    abszero.services.kanata.enable = mkDefault true;

    hardware = {
      bluetooth.enable = true;
      enableRedistributableFirmware = true;
    }
    // optionalAttrs (options.hardware ? framework.enableKmod) {
      # Disable as it causes weird infinite recursion with cachyos kernel by accessing boot.kernelPatches
      framework.enableKmod = false;
    };

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [
        "cros_ec"
        "cros_ec_lpcs"
        "kvm-intel"
      ];
    };

    services = {
      # Even stable BIOS versions are marked as test versions in LVFS
      # github.com/NixOS/nixos-hardware/blob/master/framework/README.md#updating-firmware
      fwupd.extraRemotes = [ "lvfs-testing" ];
      kanata.keyboards.framework-12-13th-gen-intel = keyboardCfg;
      thermald.enable = true;
    };
  };
}
