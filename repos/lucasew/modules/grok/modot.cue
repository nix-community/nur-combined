package module

modules: "grok": config: {}

file: home: {
		".grok/config.toml": {
			type: "toml"
			values: {
				hints: {worktree_tip_dismissed: true}
				cli: {installer: "internal"}
				ui: {
					max_thoughts_width:   120
					fork_secondary_model: "grok-build"
					yolo:                 false
					compact_mode:         false
					permission_mode:      "always-approve"
				}
				telemetry: {trace_upload: true}
				marketplace: {
					default_skills_installs_purged: true
					sources: [{
						name: "plugin-marketplace"
						git:  "https://github.com/xai-org/plugin-marketplace.git"
					}]
				}
				models: {
					default:                  "grok-4.7"
					default_reasoning_effort: "xhigh"
				}
				model: {
					"grok-4.6": {
						model:                     "grok-4.6"
						base_url:                  "https://cli-chat-proxy.grok.com/v1"
						supports_reasoning_effort: true
					}
					"grok-4.7": {
						model:                     "grok-4.7"
						base_url:                  "https://cli-chat-proxy.grok.com/v1"
						supports_reasoning_effort: true
					}
				}
				mcp_servers: {
					rod: {
						command: "rod-mcp"
						args: [
							"--headless",
							"--no-banner",
							"--compact-snapshot",
							"--omit-images",
							"--no-clone",
							"--browser-bin-path",
							browser.webapp,
							"--data-dir",
							"\(runtime.home)/.cache/rod-mcp",
						]
						startup_timeout_sec: 60
						enabled:             true
					}
				}
			}
		}
	}
