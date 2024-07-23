{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.keyboard.halo65;

  keyboardCfg = {
    extraDefCfg = ''
      danger-enable-cmd yes
      process-unmapped-keys yes
      log-layer-changes no
    '';
    config = ''
      (defsrc
        esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc del
        tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    pgup
        caps a    s    d    f    g    h    j    k    l    ;    '         ret  pgdn
        lsft z    x    c    v    b    n    m    ,    .    /         rsft up   end
        lctl lmet lalt           spc            ralt                left down rght)

      (deflayer canary
        @>q  _    _    _    _    _    _    _    _    _    _    _    +    _    _
        tab  w    l    y    p    k    z    x    o    u    ;    _    _    _    _
        esc  c    r    s    t    b    f    n    e    i    a    _         @<>r _
        @ls  j    v    d    g    q    m    h    /    ,    .         @rs  _    _
        @lc  @lm  @la            _              @ra                 _    _    _)

      (deflayer qwerty
        @>c  _    _    _    _    _    _    _    _    _    _    _    +    _    _
        tab  q    w    e    r    t    y    u    i    o    p    _    _    _    _
        esc  a    s    d    f    g    h    j    k    l    ;    _         @<>r _
        lsft z    x    c    v    b    n    m    ,    .    /         rsft _    _
        lctl lmet lalt           _              ralt                _    _    _)

      (deflayer shift
        _    _    _    _    _    _    _    _    _    _    _    _    @=   _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _    _
        _    _    _    _    _    _    _    _    _    _    _         _    _    _
        _    _    _              _              _                   _    _    _)

      (deflayer raise
        _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _    _
        _    _    _    _    _    _    _    _    _    _    _         _    _    _
        _    _    _              _              _                   _    _    _)

      (defalias
        >q  (tap-dance 150 (` (layer-switch qwerty)))
        >c  (tap-dance 150 (` (layer-switch canary)))
        <>r (tap-hold-press 150 150 ret (layer-while-held raise))
        ls  (multi lsft (layer-while-held shift))
        lc  (multi lctl (layer-while-held qwerty))
        lm  (multi lmet (layer-while-held qwerty))
        la  (multi lalt (layer-while-held qwerty))
        rs  (multi rsft (layer-while-held shift))
        ra  (multi ralt (layer-while-held qwerty))
        =   (multi (release-key lsft) (release-key rsft) =))
    '';
  };
in

{
  imports = [
    ../../../../lib/modules/config/abszero.nix
    ../../services/hardware/kanata.nix
  ];

  options.abszero.hardware.keyboard.halo65.enable = mkExternalEnableOption config "halo65 configuration";

  config = mkIf cfg.enable {
    abszero.services.kanata.enable = true;

    services = {
      # Add permanent static name when connected via Bluetooth
      udev.extraRules = ''
        KERNEL=="event[0-9]*", SUBSYSTEM=="input", \
        ATTRS{phys}=="b4:0e:de:c7:65:27", ACTION=="add", \
        SYMLINK+="input/bt-halo65"
      '';

      # It is not possible to put all three devices in one config because the
      # service is only activated when all devices are found
      kanata.keyboards = {
        halo65-wired = keyboardCfg // {
          devices = [ "/dev/input/by-id/usb-BY_Tech_NuPhy_Halo65-event-kbd" ];
        };
        halo65-wifi = keyboardCfg // {
          devices = [ "/dev/input/by-id/usb-CX_2.4G_Wireless_Receiver-event-kbd" ];
        };
        halo65-bt = keyboardCfg // {
          devices = [ "/dev/input/bt-halo65" ];
        };
      };
    };
  };
}
