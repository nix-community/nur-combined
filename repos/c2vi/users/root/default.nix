{ self, config, secretsDir, ... }:
{
	home-manager.users.root = import ./home.nix;
  home-manager.extraSpecialArgs = {
    inherit self secretsDir;
    hostname = config.networking.hostName;
    test = 3;
  };
}
