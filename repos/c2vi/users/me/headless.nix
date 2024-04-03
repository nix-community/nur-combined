{ self, config, inputs, system, ... }:
{
	users.users.me = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
		password = "changeme";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" "plugdev" ]; # Enable ‘sudo’ for the user.
	};

  home-manager.extraSpecialArgs = {
    inherit self system;
    hostname = config.networking.hostName;
  };

  home-manager.users.me = import ../common/home.nix;

  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"
  ];


}
