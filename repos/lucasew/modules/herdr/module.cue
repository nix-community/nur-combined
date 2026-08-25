package module

module: {
	meta: {
		requires: []
		recommends: []
	}
	config: {}
	file: {
		".config/herdr/config.toml": {
			type: "toml"
			values: {
				onboarding: false
				theme: {name: "catppuccin"}
				ui: {agent_panel_sort: "priority"}
			}
		}
	}
}
