package module

#hex: {
	for k, v in workspaced.modules.base16.config if k =~ "^base" {
		(k): "#\(v)"
	}
}

module: {
	meta: {
		requires: ["base16"]
		recommends: []
	}
	config: {}
	file: {
		".config/alacritty/colors.toml": {
			type: "toml"
			values: {
				colors: {
					primary: {background: #hex.base00, foreground: #hex.base05}
					cursor: {text: #hex.base00, cursor: #hex.base05}
					normal: {
						black:   #hex.base00
						red:     #hex.base08
						green:   #hex.base0B
						yellow:  #hex.base0A
						blue:    #hex.base0D
						magenta: #hex.base0E
						cyan:    #hex.base0C
						white:   #hex.base05
					}
					bright: {
						black:   #hex.base03
						red:     #hex.base08
						green:   #hex.base0B
						yellow:  #hex.base0A
						blue:    #hex.base0D
						magenta: #hex.base0E
						cyan:    #hex.base0C
						white:   #hex.base07
					}
				}
			}
		}
	}
}
