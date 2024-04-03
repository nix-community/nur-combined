{ workDir, pkgs, ... } : {


  ############################### desktop ###############################
  /*
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = with pkgs; [
    tightvnc
  ];

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = true;
  services.blueman.enable = true;
	hardware.bluetooth.enable = true;
  */

  ############################# kilian #############################
  users.users.me.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/yBJcfkHRF5HScWLuaE+jKQQ2BczpKKpHihgc5JmxB kilian@idk"
  ];

  users.users.kilian.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/yBJcfkHRF5HScWLuaE+jKQQ2BczpKKpHihgc5JmxB kilian@idk"
  ];

	users.users.kilian = {
   	isNormalUser = true;
   	#passwordFile = "${secretsDir}/me-pwd";
		password = "hi";
   	extraGroups = [ "networkmanager" "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
	};
  programs.bash.shellInit = builtins.readFile "${workDir}/config/gitignore/killian_bashrc";

}
