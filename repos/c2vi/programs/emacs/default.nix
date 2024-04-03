{ inputs, self, ... }:
{
	imports = [
		inputs.nix-doom-emacs.hmModule
	];
	programs.doom-emacs = {
		enable = true;
		doomPrivateDir = "${self}/programs/emacs";
	};
}
