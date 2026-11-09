package module

// options.<app>.palette already holds the app's colors with a leading "#".
// A module that needs a different mapping overrides entries here.
options: {
	palette: options.base16.palette
}

file: home: {
	".config/alacritty/colors.toml": {
		type: "toml"
		values: {
			colors: {
				primary: {
					background: options.base16_alacritty.palette.base00
					foreground: options.base16_alacritty.palette.base05
				}
				cursor: {
					text:   options.base16_alacritty.palette.base00
					cursor: options.base16_alacritty.palette.base05
				}
				normal: {
					black:   options.base16_alacritty.palette.base00
					red:     options.base16_alacritty.palette.base08
					green:   options.base16_alacritty.palette.base0B
					yellow:  options.base16_alacritty.palette.base0A
					blue:    options.base16_alacritty.palette.base0D
					magenta: options.base16_alacritty.palette.base0E
					cyan:    options.base16_alacritty.palette.base0C
					white:   options.base16_alacritty.palette.base05
				}
				bright: {
					black:   options.base16_alacritty.palette.base00
					red:     options.base16_alacritty.palette.base08
					green:   options.base16_alacritty.palette.base0B
					yellow:  options.base16_alacritty.palette.base0A
					blue:    options.base16_alacritty.palette.base0D
					magenta: options.base16_alacritty.palette.base0E
					cyan:    options.base16_alacritty.palette.base0C
					white:   options.base16_alacritty.palette.base07
				}
			}
		}
	}
}
