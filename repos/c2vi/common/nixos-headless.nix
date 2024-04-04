{ lib, ... }:

# config that i use on all my hosts, that run native nixos
# excluding for example my phone phone

{ 
	system.stateVersion = lib.mkDefault "23.05"; # Did you read the comment?


	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		#keyMap = "at";
		useXkbConfig = true; # use xkbOptions in tty.
	};
}

