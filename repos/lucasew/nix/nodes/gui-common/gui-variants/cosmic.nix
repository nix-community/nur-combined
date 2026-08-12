{ config, lib, ... }: {
	config = lib.mkIf config.services.desktopManager.cosmic.enable {
	  services.displayManager.cosmic-greeter.enable = true;
	};
}
