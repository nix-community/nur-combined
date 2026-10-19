package module

#hex: {
	for k, v in modules.base16.config if k =~ "^base" {
		(k): "#\(v)"
	}
}

modules: "base16-herdr": config: {}

// Herdr 0.8.2+ fills the sidebar from sidebar_bg. 0.8.0 leaves it
// unpainted, so the outer terminal background shows through.
// The active tab is panel_bg text on the accent fill.
file: home: {
	".config/herdr/config.toml": {
		type: "toml"
		values: {
			theme: custom: {
				accent:        #hex.base0D
				panel_bg:      #hex.base00
				sidebar_bg:    #hex.base00
				active_row_bg: #hex.base02
				selection_bg:  #hex.base03
				surface0:      #hex.base02
				surface1:      #hex.base03
				surface_dim:   #hex.base04
				overlay0:      #hex.base04
				overlay1:      #hex.base05
				text:          #hex.base05
				subtext0:      #hex.base04
				mauve:         #hex.base0E
				green:         #hex.base0B
				yellow:        #hex.base0A
				red:           #hex.base08
				blue:          #hex.base0D
				teal:          #hex.base0C
				peach:         #hex.base09
			}
		}
	}
}
