{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.dell-inspiron-7405;

  keyboardCfg = {
    devices = [
      # Keyboard
      "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      # Power button
      "/dev/input/power_button"
    ];
    extraDefCfg = ''
      danger-enable-cmd yes
      process-unmapped-keys yes
      log-layer-changes no
    '';
    config = ''
      (defsrc
        esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  ins  del  ;;powr
        `    1    2    3    4    5    6    7    8    9    0    -    =    bspc
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
        caps a    s    d    f    g    h    j    k    l    ;    '         ret
        lsft z    x    c    v    b    n    m    ,    .    /              rsft
        lctl lmet lalt           spc            ralt rctl pgup up   pgdn
                                                          left down rght)

      (deflayer canary
        @>q  _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
        _    _    _    _    _    _    _    _    _    _    _    _    +    _
        _    w    l    y    p    k    z    x    o    u    ;    _    _    _
        @esc c    r    s    t    b    f    n    e    i    a    _         _
        @ls  j    v    d    g    q    m    h    /    ,    .              @rs
        _    _    _              _              _    _    _    _    _
                                                          _    _    _)

      (deflayer qwerty
        @>c  _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
        _    _    _    _    _    _    _    _    _    _    _    _    +    _
        _    q    w    e    r    t    y    u    i    o    p    _    _    _
        @esc a    s    d    f    g    h    j    k    l    ;    _         _
        @ls  z    x    c    v    b    n    m    ,    .    /              @rs
        _    _    _              _              _    _    _    _    _
                                                          _    _    _)

      (deflayer shift
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
        _    _    _    _    _    _    _    _    _    _    _    _    @=   _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _
        _    _    _    _    _    _    _    _    _    _    _              _
        _    _    _              _              _    _    _    _    _
                                                          _    _    _)

      (deflayer lower
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    left down up   rght _         _
        _    _    _    _    _    _    _    _    _    _    _              _
        _    _    _              _              _    _    _    _    _
                                                          _    _    _)

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

  options.abszero.hardware.dell-inspiron-7405.enable = mkExternalEnableOption config ''
    Dell Inspiron 7405 configuration complementary to
    `inputs.nixos-hardware.nixosModules.dell-inspiron-7405`. Due to the
    nixos-hardware module being effective on import, it is not imported by this
    module; you have to import it yourself
  '';

  config = mkIf cfg.enable {
    abszero.services.kanata.enable = true;

    hardware.bluetooth.enable = true;

    boot = {
      initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ "kvm-amd" ];
    };

    services = {
      fwupd.enable = true; # Firmware updates

      # Add permanent name for power button
      udev.extraRules = ''
        KERNEL=="event[0-9]*", SUBSYSTEM=="input", \
        ATTRS{name}=="Power Button", \
        ACTION=="add", SYMLINK+="input/power_button"
      '';

      kanata.keyboards.dell-inspiron-7405 = keyboardCfg;
    };
  };
}
