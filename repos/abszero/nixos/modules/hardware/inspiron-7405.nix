{ inputs, config, lib, ... }:

let inherit (lib) mkIf; in

{
  imports = [
    inputs.nixos-hardware.nixosModules.dell-inspiron-7405
    ../services/hardware/kanata.nix
  ];

  hardware.bluetooth.enable = true;

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
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
    kanata.keyboards.inspiron-7405 = mkIf config.abszero.services.kanata.enable
      {
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
            tab  w    l    y    p    k    z    x    o    u    ;    _    _    _
            esc  c    r    s    t    b    f    n    e    i    a    _         _
            @ls  j    v    d    g    q    m    h    /    ,    .              @rs
            @lc  @lm  @la            _              @ra  @rc  _    _    _
                                                              _    _    _)

          (deflayer qwerty
            @>c  _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
            _    _    _    _    _    _    _    _    _    _    _    _    +    _
            tab  q    w    e    r    t    y    u    i    o    p    _    _    _
            esc  a    s    d    f    g    h    j    k    l    ;    _         _
            lsft z    x    c    v    b    n    m    ,    .    /              rsft
            lctl lmet lalt           _              ralt rctl _    _    _
                                                              _    _    _)

          (deflayer shift
            _    _    _    _    _    _    _    _    _    _    _    _    _    _    _    ;;_
            _    _    _    _    _    _    _    _    _    _    _    _    @=   _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _         _
            _    _    _    _    _    _    _    _    _    _    _              _
            _    _    _              _              _    _    _    _    _
                                                              _    _    _)

          (defalias
            >q (tap-dance 150 (caps (layer-switch qwerty)))
            >c (tap-dance 150 (caps (layer-switch canary)))
            ls (multi lsft (layer-while-held shift))
            lc (multi lctl (layer-while-held qwerty))
            lm (multi lmet (layer-while-held qwerty))
            la (multi lalt (layer-while-held qwerty))
            rs (multi rsft (layer-while-held shift))
            rc (multi rctl (layer-while-held qwerty))
            ra (multi ralt (layer-while-held qwerty))
            =  (multi (release-key lsft) (release-key rsft) =))
        '';
      };
  };
}
