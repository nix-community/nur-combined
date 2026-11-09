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
