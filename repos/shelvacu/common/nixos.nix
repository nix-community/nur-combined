{
  lib,
  config,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  imports = [
    ../nixos-modules
    {
      options.vacu.underTest = lib.mkOption {
        default = false;
        type = lib.types.bool;
      };
    }
  ];
  programs = {
    mosh.enable = true;
    nix-ld.enable = true;
    screen = {
      enable = true;
      screenrc = ''
        defscrollback 10000
        termcapinfo xterm* ti@:te@
        maptimeout 5
      '';
    };
    tmux = {
      enable = true;
      clock24 = true;
      extraConfig = "set -g mouse on";
    };
  };

  networking.hostName = lib.mkIf (config.vacu.hostName != null) config.vacu.hostName;
  system.nixos.tags = [ "vacu${config.vacu.versionId}" ];
  console.keyMap = lib.mkDefault "us";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = "America/Los_Angeles";

  services.openssh.settings = {
    # require public key authentication for better security
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "prohibit-password";
  };

  security.sudo.wheelNeedsPassword = false;

  security.pki.certificates = config.vacu.rootCAs;

  systemd.services.nix-daemon.serviceConfig.Nice = "10";

  # rules for openterface
  services.udev.extraRules = lib.mkIf config.vacu.isGui ''
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="534f", ATTRS{idProduct}=="2109", TAG+="uaccess"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="534f", ATTRS{idProduct}=="2132", TAG+="uaccess"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
    SUBSYSTEM=="usb",    ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534f", ATTRS{idProduct}=="2109", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534f", ATTRS{idProduct}=="2132", TAG+="uaccess"
    SUBSYSTEM=="ttyUSB", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
    SUBSYSTEM=="ttyACM", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="fe0c", TAG+="uaccess"
  '';
}
