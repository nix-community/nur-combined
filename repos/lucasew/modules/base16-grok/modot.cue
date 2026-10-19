package module

modules: "base16-grok": config: {}

// Grok has no custom palette. The terminal theme uses the host ANSI colors,
// which base16-alacritty already paints from this palette.
file: home: {
	".grok/config.toml": {
		type: "toml"
		values: {
			features: terminal_theme: true
			ui: theme: "terminal"
		}
	}
}
