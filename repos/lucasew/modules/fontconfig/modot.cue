package module

options: {
	serif:      string | *"DejaVu Serif"
	sans_serif: string | *"DejaVu Sans"
	monospace:  string | *"DejaVu Sans Mono"
	emoji:      string | *"Noto Color Emoji"
}

file: home: {
		".config/fontconfig/fonts.conf": {
			type: "xml"
			values: {
				fontconfig: {
					alias: [
						{family: "serif", prefer: {family: options.fontconfig.serif}},
						{family: "sans", prefer: {family: options.fontconfig.sans_serif}},
						{family: "monospace", prefer: {family: options.fontconfig.monospace}},
						{family: "emoji", prefer: {family: options.fontconfig.emoji}},
					]
				}
			}
		}
	}
