{ ... }:
{
	# The home.stateVersion option does not have a default and must be set
	home.stateVersion = "23.05";

   imports = [
      ../../programs/ssh.nix
   ];
   
}
