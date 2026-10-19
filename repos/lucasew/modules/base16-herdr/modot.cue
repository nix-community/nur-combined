package module

#hex: {
	for k, v in modules.base16.config if k =~ "^base" {
		(k): "#\(v)"
	}
}

modules: "base16-herdr": config: {}

// Herdr 0.8.0 draws the active tab as panel_bg text on an accent fill.
// Material You puts the contrasting primary in base0B. base0C–base0F are
// containers and match the surface, so they wash the tab out.
file: home: {
	".config/herdr/config.toml": {
		type: "toml"
		values: {
			theme: custom: {
				accent:      #hex.base0B
				panel_bg:    #hex.base00
				surface0:    #hex.base02
				surface1:    #hex.base03
				surface_dim: #hex.base01
				overlay0:    #hex.base06
				overlay1:    #hex.base05
				text:        #hex.base05
				subtext0:    #hex.base06
				mauve:       #hex.base09
				green:       #hex.base0B
				yellow:      #hex.base0A
				red:         #hex.base08
				blue:        #hex.base07
				teal:        #hex.base09
				peach:       #hex.base08
			}
		}
	}
}
