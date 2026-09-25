package module

modules: "codex": config: {}

file: home: {
		".codex/config.toml": {
			type: "toml"
			values: {
				model:                  "gpt-5.3-codex"
				model_reasoning_effort: "medium"
				personality:            "pragmatic"
				projects: {
					"\(runtime.dotfiles_root)": {trust_level: "trusted"}
					"\(runtime.dotfiles_root)/workspaced": {trust_level: "trusted"}
				}
				notice: {
					model_migrations: {
						"gpt-5.2-codex": "gpt-5.3-codex"
					}
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
				plugins: {
					"hugging-face@openai-curated": {enabled: true}
					"vercel@openai-curated":       {enabled: true}
					"github@openai-curated":       {enabled: true}
					"superpowers@openai-curated":  {enabled: true}
				}
			}
		}
	}
