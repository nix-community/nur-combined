{ config, lib, ... }:

let
  inherit (lib) mkIf singleton;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.xiaomi-redmibook-16-pro-2024;

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
        `    1    2    3    4    5    6    7    8    9    0    -    =    bspc home
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    end
        caps a    s    d    f    g    h    j    k    l    ;    '         ret  pgup
        lsft z    x    c    v    b    n    m    ,    .    /         rsft up   pgdn
        lctl lmet lalt           spc            ralt      rctl      left down rght)

      (deflayer canary
        @>q  _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    +    _    _
        _    w    l    y    p    k    z    x    o    u    ;    _    _    _    _
        @esc c    r    s    t    b    f    n    e    i    a    _         _    _
        @ls  j    v    d    g    q    m    h    /    ,    .         @rs  _    _
        _    _    _              _              _         _         _    _    _)

      (deflayer qwerty
        @>c  _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    +    _    _
        _    q    w    e    r    t    y    u    i    o    p    _    _    _    _
        @esc a    s    d    f    g    h    j    k    l    ;    _         _    _
        @ls  z    x    c    v    b    n    m    ,    .    /         @rs  _    _
        _    _    _              _              _         _         _    _    _)

      (deflayer shift
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    @=   _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _    _
        _    _    _    _    _    _    _    _    _    _    _         _    _    _
        _    _    _              _              _         _         _    _    _)

      (deflayer lower
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    left down up   rght _         _    _
        _    _    _    _    _    _    _    _    _    _    _         _    _    _
        _    _    _              _              _         _         _    _    _)

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

  options.abszero.hardware.xiaomi-redmibook-16-pro-2024.enable = mkExternalEnableOption config ''
    Xiaomi Redmibook 16 Pro 2024 configuration complementary to
    `inputs.nixos-hardware.nixosModules.xiaomi-redmibook-16-pro-2024`. Due to
    the nixos-hardware module being effective on import, it's not imported by
    this module; you have to import them yourself
  '';

  config = mkIf cfg.enable {
    abszero.services.kanata.enable = true;

    hardware.bluetooth.enable = true;

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
      ];
      kernelModules = [ "kvm-intel" ];
    };

    services.kanata.keyboards.xiaomi-redmibook-16-pro-2024 = keyboardCfg;
  };
}
