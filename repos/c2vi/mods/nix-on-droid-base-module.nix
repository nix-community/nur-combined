{ ... }: {

  services.openssh = {
  		enable = true;
      allowSFTP = true;

      extraConfig = ''
        X11UseLocalhost no
  		  PasswordAuthentication no
  		  KbdInteractiveAuthentication no
  		  PermitRootLogin no
        X11Forwarding yes
      '';
	};

  home-manager.useUserPackages = false;

  home-manager.config = {
	  home.stateVersion = "23.05";

    home.file.".ssh/authorized_keys".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPAgNB1nsKZ5KXnmR6KWjQLfwhFKDispw24o8M7g/nbR me@bitwarden
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/mCDzCBE2J1jGnEhhtttIRMKkXMi1pKCAEkxu+FAim me@main
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGw5kYmBQl8oolNg2VUlptvvSrFSESfeuWpsXRovny0x me@phone
    '';
  };

}
