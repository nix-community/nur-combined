{ self, pkgs, ... }:
{
	imports = [
		../mods/battery_monitor.nix
	];

	modules.battery_monitor.enable = true;

	# Enable the X11 windowing system.
  services.xserver = {
	  enable = true;
    displayManager = {
	    defaultSession = "none+xmonad";
   	  sessionCommands = ''
			  xmobar ${self}/misc/xmobar.hs &

			  # the sleep is aparently needed, so that xmonad is already fully started up??
			  sleep 2 && \
			  ${pkgs.xorg.xmodmap}/bin/xmodmap \
				  -e "clear control" \
				  -e "clear mod1" \
				  -e "keycode 64 = Control_L" \
				  -e "keycode 37 = Alt_L" \
				  -e "add control = Control_L" \
				  -e "add mod1 = Alt_L" \
				  &
   	  '';
	  };
    
    #displayManager.gdm = {
      #enable = true;
    #};

    #/*
    displayManager.lightdm = {
      enable = true;
      greeters.enso = {
        enable = true;
        blur = true;
        extraConfig = ''
          default-wallpaper=/usr/share/streets_of_gruvbox.png
        '';
      };
    };
    # */
    layout = "at";
	};

	# xdg portals
	xdg.portal = {
		enable = true;
		extraPortals = [
			pkgs.xdg-desktop-portal-gtk
			#pkgs.xdg-desktop-portal-termfilechooser
			(pkgs.callPackage ../mods/xdg-desktop-portal-termfilechooser/default.nix {})
		];
	};


	# Configure keymap in X11
	# services.xserver.xkbOptions = "eurosign:e,caps:escape";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = true;
  services.blueman.enable = true;
	hardware.bluetooth.enable = true;

	# Enable touchpad support (enabled default in most desktopManager).
	services.xserver.libinput.enable = true;

	# xmonad
	services.xserver.windowManager.xmonad = {
   	enable = true;
		
   	config = builtins.readFile "${self}/misc/xmonad.hs";
   	#config = "${confDir}/misc/xmo";
   	enableContribAndExtras = true;
   	extraPackages = hpkgs: [
      	hpkgs.xmobar
      	#hpkgs.xmonad-screenshot
   	];
   	ghcArgs = [
      	"-hidir /tmp" # place interface files in /tmp, otherwise ghc tries to write them to the nix store
      	"-odir /tmp" # place object files in /tmp, otherwise ghc tries to write them to the nix store
      	#"-i${xmonad-contexts}" # tell ghc to search in the respective nix store path for the module
    	];
   };
}
