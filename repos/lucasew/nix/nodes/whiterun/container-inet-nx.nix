{ pkgs, config, ... }:
let
  containerUser = "test";
  super-pkgs = pkgs;
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/chromenx-container 0700 root root - -"
  ];

  containers.chrome-nx = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.68.1";
    localAddress = "192.168.68.3";
    forwardPorts = [
      {
        hostPort = 2222;
        containerPort = 22;
        protocol = "tcp";
      }
    ];
    bindMounts = {
      chrome-profile = {
        mountPoint = "/home";
        hostPath = "/var/lib/chromenx-container";
        isReadOnly = false;
      };
    };
    config = {pkgs, ...}: {
      services.xserver = {
        enable = true;
        desktopManager = {
          xterm.enable = false;
          # mate.enable = true;
          xfce.enable = true;
        };
        displayManager.lightdm.enable = false;
      };
      hardware.pulseaudio = {
        enable = true;
        extraModules = [
          # super-pkgs.pulseaudio-module-xrdp
        ];
      };
      environment.systemPackages = with pkgs; [
        chromium
        firefox
        # super-pkgs.pulseaudio-module-xrdp
      ];
      services.x2goserver.enable = true;
      services.openssh.enable = true;
      users.users.test = {
        isNormalUser = true;
        extraGroups = [ "wheel" "video" "render" "audio"];
        initialPassword = "test";
        uid = 6969;
      };

      system.stateVersion = "23.11";
    };
  };
}
