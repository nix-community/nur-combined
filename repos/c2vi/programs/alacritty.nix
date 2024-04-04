{ pkgs, ... }:
{
	programs.alacritty = {
		enable = true;

      # overwrite alacritty package.... to the one with smooth scrolling....
      # for it you also need to add cursor.smooth_factor to the alacritty settings
      /*
		package = pkgs.alacritty.overrideAttrs ( final: prev: rec {
		   src = pkgs.fetchFromGitHub {
			   owner = "gregthemadmonk";
            repo = "alacritty";
            rev = "master";
            sha256 = "2XFHVqXR5RyXpdNd+oimrwGHl4k0qaMzLO+WVGWnQ/M=";
		   };
         #cargoSha256 = "0000000000000000000000000000000000000000000000000000";
         #cargoSha256 = "";

         cargoDeps = prev.cargoDeps.overrideAttrs (_: {
            inherit src;
            outputHash = "sha256-6Gt9ikXrcBXtxHRSvKPEoLoVituxc3rTVDoWlGR4V7A=";
            # ...
         });
      });
      #*/
		settings = {
         #cursor.smooth_factor = 0.5;
			font = {
			  normal = {
				 family = "Hack";
				 style = "Regular";
			  };

			  bold = {
				 family = "Hack";
				 style = "Bold";
			  };

			  italic = {
				 family = "Hack";
				 style = "Italic";
			  };

			  bold_italic = {
				 family = "Hack";
				 style = "Bold Italic";
			  };

			  size = 8;
			};

			# Dracula theme for alacritty
			colors = {
				primary = {
					background = "#282a36";
					foreground = "#f8f8f2";
					bright_foreground = "#ffffff";
				};
				cursor = {
				 text = "CellBackground";
				 cursor = "CellForeground";
				};
				vi_mode_cursor = {
					text = "CellBackground";
					cursor = "CellForeground";
				};
				search = {
					matches = {
						foreground = "#44475a";
						background = "#50fa7b";
					};
					focused_match = {
						foreground = "#44475a";
						background = "#ffb86c";
					};
				};
				footer_bar = {
					background = "#282a36";
					foreground = "#f8f8f2";
				};
			  	hints = {
					start = {
						foreground = "#282a36";
						background = "#f1fa8c";
					};
				 	end = {
						foreground = "#f1fa8c";
						background = "#282a36";
					};
				};
				line_indicator = {
					foreground = "None";
					background = "None";
				};
			  	selection = {
					 text = "CellForeground";
					 background = "#44475a";
				};
			  	normal = {
				 	black = "#21222c";
				 	red = "#ff5555";
				 	green = "#50fa7b";
				 	yellow = "#f1fa8c";
				 	blue = "#bd93f9";
				 	magenta = "#ff79c6";
				 	cyan = "#8be9fd";
				 	white = "#f8f8f2";
				};
			  	bright = {
				 	black = "#6272a4";
				 	red = "#ff6e6e";
				 	green = "#69ff94";
				 	yellow = "#ffffa5";
				 	blue = "#d6acff";
				 	magenta = "#ff92df";
				 	cyan = "#a4ffff";
				 	white = "#ffffff";
				};
			};

			key_bindings = [
			  { key = "V"; mods = "Control|Shift"; action = "Paste"; }
			  { key = "C"; mods = "Control|Shift"; action = "Copy"; }
			  { key = "J"; mods = "Control"; chars = ''\x1b\x5b\x42''; }
			  { key = "K"; mods = "Control"; chars = ''\x1b\x5b\x41''; }
			  { key = "H"; mods = "Control"; chars = ''\x1b\x5b\x44''; }
			  { key = "L"; mods = "Control"; chars = ''\x1b\x5b\x43''; }
			];
		};
	};
}
