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


  # to build rpi images
  boot.binfmt.emulatedSystems = [ 
    "aarch64-linux"
    "armv7l-linux"
  ];


  ######################### networking #####################################

  networking.hostName = "mosatop";
	networking.firewall.allowPing = true;
	networking.firewall.enable = true;
	networking.firewall.allowedUDPPorts = [
  	3702 # wsdd
    51820  # wireguard
    24454 # minecraft voice chat
	];
	networking.firewall.allowedTCPPorts = [
    2222 # sshd
    8888 # general use
    9999 # general use
    25565 # minecraft
    29901
    29902
    29903
    29904
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
