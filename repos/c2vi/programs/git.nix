{ pkgs, ... }:
{
	programs.git = {
		enable = true;
		userName  = "Sebastian Moser";
		userEmail = "sebastian@c2vi.dev";

    extraConfig.credential.helper = "manager";
    extraConfig.credential."https://git.htlec.org".username = "c2vi";
    extraConfig.credential.credentialStore = "cache";
	
		extraConfig = {
			core.editor = "nvim";
			core.color.ui = true;
			core.pager = "delta";
			core.excludesfile = "~/.config/git/gitignore";
		};
	};
  home.packages = [ pkgs.git-credential-manager ];
}
