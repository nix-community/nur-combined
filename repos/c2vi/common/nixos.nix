{ lib, self, ... }:

# config that i use on all my hosts, that run native nixos
# excluding for example my phone phone

{ 
	system.stateVersion = "23.05"; # Did you read the comment?


	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		#keyMap = "at";
		useXkbConfig = true; # use xkbOptions in tty.
	};

  system.activationScripts.addBinBash = lib.stringAfter [ "var" ] ''
    # there is no /bin/bash
    # https://discourse.nixos.org/t/add-bin-bash-to-avoid-unnecessary-pain/5673
    ln -nsf /run/current-system/sw/bin/bash /bin/bash
 '';

  # the hosts file
  networking.extraHosts = ''
    ${builtins.readFile "${self}/misc/my-hosts"}
    ${builtins.readFile "${self}/misc/my-hosts-me"}
  '';
  environment.etc.current_hosts.text = builtins.readFile "${self}/misc/my-hosts-me";
  environment.etc.current_hosts.mode = "rw";
}

