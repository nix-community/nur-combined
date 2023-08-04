{ pkgs, config, ... }:
let
  containerUser = "test";
  super-pkgs = pkgs;
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/chromerdp-container 0700 root root - -"
  ];

  containers.chrome-rdp = {
    autoStart = true;
    hostBridge = "br-chromerdp";
    forwardPorts = [
      {
        hostPort = config.containers.chrome-rdp.services.xrdp.port;
        containerPort = config.containers.chrome-rdp.services.xrdp.port;
        protocol = "tcp";
      }
    ];
    bindMounts = {
      chrome-profile = {
        mountPoint = "/home";
        hostPath = "/var/lib/chromerdp-container";
        isReadOnly = false;
      };
      sound = {
        mountPoint = "/dev/snd";
        hostPath = "/dev/snd";
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
          super-pkgs.pulseaudio-module-xrdp
        ];
      };
      environment.systemPackages = with pkgs; [
        chromium
        firefox
        super-pkgs.pulseaudio-module-xrdp
      ];
      services.xrdp = {
        enable = true;
        openFirewall = true;
        defaultWindowManager = ''xfce4-session'';
      };
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
