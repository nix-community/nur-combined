{ self, config, inputs, ... }:
{
	users.users.server = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
    group = "server";
		password = "changeme";
	};
  users.groups.server = {};

  home-manager.extraSpecialArgs = {
    inherit self;
    hostname = config.networking.hostName;
  };

  home-manager.users.server = import ../common/home.nix;

  users.users.server.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone"
  ];


}
