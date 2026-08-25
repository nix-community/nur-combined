package module

module: {
	meta: {
		requires: []
		recommends: []
	}
	config: {}
	file: {
		".config/helix/config.toml": {
			type: "toml"
			values: {
				theme: "base16"
				editor: {
					"cursor-shape": {insert: "bar"}
					lsp: {"display-messages": true}
					"soft-wrap": {enable: true}
				}
			}
		}
	}
}
