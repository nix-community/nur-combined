{ ... }:
{
	programs.zathura = {
		enable = true;
		options = {
			selection-clipboard = "clipboard";
			roll-step = 40;
		};
		mappings = {
			"<C-y>" = ''scroll down'';
			"<C-x>" = ''scroll up'';
			"<C-o>" = ''scroll left'';
			"<C-p>" = ''scroll right'';

			"j" = ''feedkeys "4<C-y>"'';
			"k" = ''feedkeys "4<C-x>"'';
			"h" = ''feedkeys "4<C-o>"'';
			"l" = ''feedkeys "4<C-p>"'';

			"J" = ''feedkeys "<C-y>"'';
			"K" = ''feedkeys "<C-x>"'';
			"H" = ''feedkeys "<C-o>"'';
			"L" = ''feedkeys "<C-p>"'';

			"y" = ''zoom in'';
			"+" = ''feedkeys "yyy"'';
			"*" = ''feedkeys "y"'';

			"x" = ''zoom out'';
			"-" = ''feedkeys "xxx"'';
			"_" = ''feedkeys "x"'';

			"n" = ''navigate next'';
			"p" = ''navigate previous'';
		};
	};
}




