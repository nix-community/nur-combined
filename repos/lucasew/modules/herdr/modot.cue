package module

modules: "herdr": config: {}

file: home: {
		".config/herdr/config.toml": {
			type: "toml"
			values: {
				onboarding: false
				theme: {name: "catppuccin"}
				ui: {agent_panel_sort: "priority"}
			}
		}
	}
