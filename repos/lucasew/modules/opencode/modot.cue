package module

options: {}

file: home: {
		".config/opencode/opencode.json": {
			type: "json"
			values: {
				"$schema": "https://opencode.ai/config.json"
				theme:     "modot"
				model: "aperture/deepseek_coding_flash"
				plugin: ["opencode-gemini-auth"]
				// Browse: drives the real browser (your tabs/logins) through the
				// Chromium extension. Runs via bunx (modot lazy tool `bun`) so there
				// is no global install and a fresh machine only needs `modot home apply`.
				// Bump the version here; `--bun` makes bun run the Node launcher.
				mcp: {
					servers: {
						browse: {
							type: "local"
							command: [
								"\(runtime.home)/.local/share/modot/shim/lazy/bun",
								"--bun",
								"x",
								"@opencode/browse@0.1.1",
								"mcp",
							]
							environment: {
								OPENCODE_BROWSER_AUTO_UPDATE: "off"
							}
						}
					}
				}
				provider: {
					aperture: {
						npm:  "@ai-sdk/openai-compatible"
						name: "Aperture"
						options: {baseURL: "https://ai.stargazer-shark.ts.net/v1"}
						models: {
							for _, model in ["qwen3.5-9b", "cyber-tiel-coder-35b", "bonsai-2-27b", "deepseek-v4.1-flash-1017", "deepseek_coding_flash"] {
								"\(model)": { name: model }
							}
						}
						
					}
				}
			}
		}
	}
