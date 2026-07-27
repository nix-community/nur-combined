{ pkgs, inputs, secretsDir, ...}:
{
  imports = [
    ../users/me/headless.nix
    ../common/wsl.nix

    inputs.networkmanager.nixosModules.networkmanager
		inputs.home-manager.nixosModules.home-manager
    ../common/all.nix
    ../common/nixos-headless.nix
  ];


  programs.bash.loginShellInit = "";
  virtualisation.docker.enable = true;
  users.users.me.extraGroups = [ "docker" ];

  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
    "armv7l-linux"
  ];


  ######################### networking #####################################

  networking.hostName = "acern";
	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	networking.firewall.allowedUDPPorts = [
  	3702 # wsdd
    51820  # wireguard
	];
	networking.firewall.allowedTCPPorts = [
    2222 # sshd
  ];


  networking.networkmanager.enable = true;

/*
  networking.networkmanager.profiles = {
    me = {
     connection = {
        id = "me";
        uuid = "fe45d3bc-21c6-41ff-bc06-c936017c6e02";
        type = "wireguard";
        autoconnect = "true";
        interface-name = "me0";
     };
      wireguard = {
        listen-port = "51820";
        private-key = builtins.readFile "${secretsDir}/wg-private-acern";
      };
      ipv4 = {
        address1 = "10.1.1.5/24";
        method = "manual";
      };
    } // (import ../common/wg-peers.nix { inherit secretsDir; }) ;
  };
  */
}
