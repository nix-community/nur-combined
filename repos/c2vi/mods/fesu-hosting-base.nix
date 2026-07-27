{ lib, pkgs, ... }:
{

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = [ "root" "@wheel" ];
  };
  nixpkgs.config.allowUnfree = true;

  boot.tmp.useTmpfs = true;

  virtualisation.docker.enable = true;

  programs.bash.shellInit = ''
    cd /root/host
    export HISTFILE=$HOME/host/bash_history
    export HISTSIZE=10000
  '';

  environment.systemPackages = with pkgs; [
    vim
    wget

    # required for ppc wiki publish.sh
    git
    rsync
    nodejs
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"
  ];
  services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "yes";

      settings.X11Forwarding = true;

      extraConfig = ''
        X11UseLocalhost no
      '';
  };

  /*
  system.activationScripts.addDefaultRoute = {
    text = ''
      ip route add default via  dev eth0
    '';
  };
  */

  networking = {
    defaultGateway = "192.168.1.4";
    # Use systemd-resolved inside the container
    # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    useHostResolvConf = lib.mkForce false;
    #useNetworkd = true;
    /*
    interfaces.eth0.ipv4.routes = [
      {
        via = "192.168.101.1";
        address = "default";
        prefixLength = 24;
      }
    ];
    */
  };
  services.resolved.enable = true;
  networking.firewall.enable = false;
  #systemd.network.enable = true;

  system.stateVersion = "24.11";
}
