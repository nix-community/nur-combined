# Still cannot boot atm
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkForce;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.hardware.redmi-book-pro-16-2024;

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
        tab  w    l    y    p    k    z    x    o    u    ;    _    _    _    _
        esc  c    r    s    t    b    f    n    e    i    a    _         _    _
        @ls  j    v    d    g    q    m    h    /    ,    .         @rs  _    _
        @lc  @lm  @la            _              @ra       @rc       _    _    _)

      (deflayer qwerty
        @>c  _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    +    _    _
        tab  q    w    e    r    t    y    u    i    o    p    _    _    _    _
        esc  a    s    d    f    g    h    j    k    l    ;    _         _    _
        lsft z    x    c    v    b    n    m    ,    .    /         rsft _    _
        lctl lmet lalt           _              ralt      rctl      _    _    _)

      (deflayer shift
        _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _    @=   _    _
        _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
        _    _    _    _    _    _    _    _    _    _    _    _         _    _
        _    _    _    _    _    _    _    _    _    _    _         _    _    _
        _    _    _              _              _         _         _    _    _)

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
in

{
  imports = [
    ../../../lib/modules/config/abszero.nix
    ../services/hardware/kanata.nix
  ];

  options.abszero.hardware.redmi-book-pro-16-2024.enable = mkExternalEnableOption config ''
    Redmi Book Pro 16 2024 configuration complementary to
    `inputs.nixos-hardware.nixosModules.common-cpu-intel`,
    `inputs.nixos-hardware.nixosModules.common-pc-laptop` and
    `inputs.nixos-hardware.nixosModules.common-pc-ssd`. Due to
    the nixos-hardware modules being effective on import, they are not imported
    by this module; you have to import them yourself
  '';

  config = mkIf cfg.enable {
    abszero.services.kanata.enable = true;

    hardware = {
      enableAllFirmware = true;
      bluetooth.enable = true;
    };

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
      ];
      # TEMP
      initrd.kernelModules = [
        "qrtr"
        "soundwire_intel"
        "ac97_bus"
        "intel_uncore_frequency"
        "intel_powerclamp"
        "hid_sensor_als"
        "crct10dif_pclmul"
        "polyval_clmulni"
        "hid_sensor_custom"
        "intel_rapl_msr"
        "ghash_clmulni_intel"
        "processor_thermal_device_pci"
        "ucsi_acpi"
        "sha1_ssse3"
        "rapl"
        "i2c_hid_acpi"
        "mei_gsc_proxy"
        "intel_ishtp_hid"
        "intel_cstate"
        "intel_pmc_core"
        "intel_uncore"
        "i2c_i801"
        "int3403_thermal"
        "intel_lpss_pci"
        "spi_nor"
        "wmi_bmof"
        "idma64"
        "int3400_thermal"
        "intel_ish_ipc"
        "mac_hid"
        "mei_me"
        "intel_vpu"
        "pinctrl_meteorlake"
        "acpi_pad"
        "acpi_tad"
        "igen6_edac"
        "pkcs8_key_parser"
        "i2c_dev"
        "crc32_pclmul"
        "crc32c_intel"
        "sha512_ssse3"
        "sha256_ssse3"
        "serio_raw"
        "aesni_intel"
        "spi_intel_pci"
        "i8042"
      ];
      kernelPackages = mkForce pkgs.linuxPackages_latest;
      kernelModules = [ "kvm-intel" ];
    };

    services.kanata.keyboards.redmi-book-pro-16-2024 = keyboardCfg;
  };
}
