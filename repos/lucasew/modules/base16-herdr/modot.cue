package module

options: {
	palette: options.base16.palette
}

// Herdr 0.8.2+ fills the sidebar from sidebar_bg. 0.8.0 leaves it
// unpainted, so the outer terminal background shows through.
// The active tab is panel_bg text on the accent fill.
file: home: {
	".config/herdr/config.toml": {
		type: "toml"
		values: {
			theme: custom: {
				accent:        options.base16_herdr.palette.base0D
				panel_bg:      options.base16_herdr.palette.base00
				sidebar_bg:    options.base16_herdr.palette.base00
				active_row_bg: options.base16_herdr.palette.base02
				selection_bg:  options.base16_herdr.palette.base03
				surface0:      options.base16_herdr.palette.base02
				surface1:      options.base16_herdr.palette.base03
				surface_dim:   options.base16_herdr.palette.base04
				overlay0:      options.base16_herdr.palette.base04
				overlay1:      options.base16_herdr.palette.base05
				text:          options.base16_herdr.palette.base05
				subtext0:      options.base16_herdr.palette.base04
				mauve:         options.base16_herdr.palette.base0E
				green:         options.base16_herdr.palette.base0B
				yellow:        options.base16_herdr.palette.base0A
				red:           options.base16_herdr.palette.base08
				blue:          options.base16_herdr.palette.base0D
				teal:          options.base16_herdr.palette.base0C
				peach:         options.base16_herdr.palette.base09
			}
		}
	}
}
