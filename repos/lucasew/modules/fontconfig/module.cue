package module

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
}
