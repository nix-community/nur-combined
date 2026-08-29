package module

#fonts: workspaced.modules.fontconfig.config

module: {
	meta: {
		requires: []
		recommends: []
	}

	config: {
		serif:      string | *"DejaVu Serif"
		sans_serif: string | *"DejaVu Sans"
		monospace:  string | *"DejaVu Sans Mono"
		emoji:      string | *"Noto Color Emoji"
	}

	file: {
		".config/fontconfig/fonts.conf": {
			type: "xml"
			values: {
				fontconfig: {
					alias: [
						{family: "serif", prefer: {family: #fonts.serif}},
						{family: "sans", prefer: {family: #fonts.sans_serif}},
						{family: "monospace", prefer: {family: #fonts.monospace}},
						{family: "emoji", prefer: {family: #fonts.emoji}},
					]
				}
			}
		}
	}
}
