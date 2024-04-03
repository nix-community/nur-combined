{ ... }:
{
	programs.git = {
		enable = true;
		userName  = "Sebastian Moser";
		userEmail = "sebastian@c2vi.dev";
	
		extraConfig = {
			core.editor = "nvim";
			core.color.ui = true;
			core.pager = "delta";
			extraConfig.core.excludesfile = "~/.config/git/gitignore";
		};
	};
}
