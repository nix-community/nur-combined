package module

options: {}

file: home: {
		".codex/config.toml": {
			type: "toml"
			values: {
				personality:            "pragmatic"
				projects: {
					"\(runtime.dotfiles_root)": {trust_level: "trusted"}
					"\(runtime.dotfiles_root)/modot": {trust_level: "trusted"}
				}
				tui: {
					status_line: [
						"model-with-reasoning",
						"project-root",
						"git-branch",
						"context-remaining",
						"five-hour-limit",
						"weekly-limit",
						"used-tokens",
						"total-input-tokens",
						"total-output-tokens",
					]
				}
			}
		}
	}
