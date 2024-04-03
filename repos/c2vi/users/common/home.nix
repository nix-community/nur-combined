{ config, pkgs, self, secretsDir, inputs, hostname, ... }:
{
	# The home.stateVersion option does not have a default and must be set
	home.stateVersion = "23.05";
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.nix-index-database.hmModules.nix-index

		# all my headless programms with their own config
		../../programs/git.nix
    ../../programs/lf/default.nix
		../../programs/bash.nix
		../../programs/ssh.nix
		../../programs/neovim.nix
  ];

  programs.nix-index.enable = false;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;

	home.sessionVariables = {
		EDITOR = "nvim";
	};

	home.sessionPath = [ "${self}/mybin" ];
  home.file = {
     
    ".subversion/config".text = ''
      [miscellany]
      global-ignores = node_modules target
    ''; # documentation for this config file: https://svnbook.red-bean.com/en/1.7/svn.advanced.confarea.html

    # rclone.conf only on main
  } // (if hostname == "main" then { ".rclone.conf".source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/rclone-conf"; } else {});

   home.packages = with pkgs; [
    borgbackup
    rclone
    archivemount
    nmon
    pkgs.hostname
		vim
		tree
		htop
		subversion
		pv
		nodejs
		neofetch
		file
		lshw
		zip
		unzip
		arp-scan
		lolcat
		comma
		delta
    jq
    wget
    tmux
    wireguard-tools
    xorg.xauth
    wakeonlan

		# python....
		(python310.withPackages (p: with p; [
			pandas
			click
			click-aliases
		]))
     #/*
		(busybox.overrideAttrs (final: prev: {
			# get only nslookup from busybox
			# because the less would overwrite the actuall less and the busybox does not have -r
			# it's a pfusch, but it works
			postInstall = prev.postInstall + ''
				echo ============ removing anything but nslookup ============
				mv $out/bin/nslookup $out/nslookup
				mv $out/bin/busybox $out/busybox

				rm $out/bin/*

				mv $out/nslookup $out/bin/nslookup
				mv $out/busybox $out/bin/busybox
			'';
		}))
     # */

    # self packaged colored bandwith meter
    (pkgs.callPackage ../../mods/cbm.nix {})

  ];

  # */

}
