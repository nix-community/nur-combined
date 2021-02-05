{pkgs, ...}:
with import ../../globalConfig.nix;
let
  randomtube = "${pkgs.callPackage "${builtins.fetchGit {
    url = "ssh://git@github.com/lucasew/randomtube.git";
    rev = "9bdb25e489685f27ec99bfafab37e183480d2a7b";
  }}" {}}/bin/randomtube";
  wrappedRandomtube = "${pkgs.wrapDotenv "randomtube.env" ''
    PATH=$PATH:${pkgs.ffmpeg}/bin
    ${randomtube} -ms 60
  ''}";
in
{
  imports = [
    ../bootstrap/default.nix
     "${flake.inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
    ../../modules/cachix/system.nix
  ];

  swapDevices = [
    { device = "/swapfile"; }
  ];

  nixpkgs.config.allowUnfree = true;
  networking.hostName = "cloudhead";
  environment.systemPackages = with pkgs; [
    dotenv
  ];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80 443
      59356 
      6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980
    ];
    allowedUDPPorts = [
      22
      80 443
      59356 
      6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980
    ];
  };
  services.zerotierone.enable = true;
  systemd = {
    services.randomtube = {
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
      };
      script = "${wrappedRandomtube}";
    };
    timers.randomtube = {
      wantedBy = [ "timers.target" ];
      partOf = [ "randomtube.service" ];
      timerConfig.OnCalendar = "*-*-* 3:00:00";
    };
  };
  users.users = {
    ${username} = {
      description = "Ademir";
    };
  };
  virtualisation.docker.enable = true;
  services.irqbalance.enable = true;

  cachix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_4;
  system.stateVersion = "20.03";
}
