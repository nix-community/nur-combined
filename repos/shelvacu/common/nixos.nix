{
  lib,
  pkgs,
  config,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  imports = [ ../nixos-modules ];
  options.vacu.underTest = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };
  config = {
    programs.mosh.enable = true;

    console = {
      keyMap = lib.mkDefault "us";
    };
    networking = lib.mkIf (config.vacu.hostName != null) { inherit (config.vacu) hostName; };
    vacu.packages."xorg-xev" = {
      enable = config.services.xserver.enable;
      package = pkgs.xorg.xev;
    };
    programs.nix-ld.enable = true;
    system.nixos.tags = [
      "vacu${config.vacu.versionId}"
      config.vacu.hostName
    ];
    environment.etc."vacu/info.json".text = builtins.toJSON config.vacu.versionInfo;
    environment.etc."chromium" = lib.mkIf config.vacu.isGui {
      source = "/run/current-system/sw/etc/chromium";
    };

    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    time.timeZone = "America/Los_Angeles";

    users.users.shelvacu = lib.mkIf (!config.vacu.isContainer) {
      openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" ];
    };
    services.openssh = {
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "prohibit-password";
    };

    nix.settings.trusted-users = lib.mkIf (!config.vacu.isContainer) [ "shelvacu" ];
    security.sudo.wheelNeedsPassword = lib.mkDefault false;

    programs.screen = {
      enable = true;
      screenrc = ''
        defscrollback 10000
        termcapinfo xterm* ti@:te@
        maptimeout 5
      '';
    };

    programs.tmux = lib.mkIf (!config.vacu.isContainer) {
      enable = true;
      extraConfig = "setw mouse";
      clock24 = true;
    };

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkForce config.vacu.nix.substituterUrls;
      extra-substituters = lib.mkForce [ ];
      trusted-public-keys = lib.mkForce config.vacu.nix.trustedKeys;
      extra-trusted-public-keys = lib.mkForce [ ];
    };

    security.pki.certificates = config.vacu.rootCAs;

    # commands.nix
    environment.pathsToLink = [
      "/share/vacufuncs"
      "/etc/chromium"
    ];
    programs.bash.interactiveShellInit = config.vacu.shell.interactiveLines;
    programs.bash.promptInit = lib.mkForce "";

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
  };
}
