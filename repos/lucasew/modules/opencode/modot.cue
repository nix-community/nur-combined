package module

modules: "opencode": config: {}

file: home: {
		".config/opencode/opencode.json": {
			type: "json"
			values: {
				"$schema": "https://opencode.ai/config.json"
				theme:     "modot"
				plugin: ["opencode-gemini-auth"]
				provider: {
					llamacpp: {
						npm:  "@ai-sdk/openai-compatible"
						name: "llama.cpp"
						options: {baseURL: "http://whiterun:38286/v1"}
						models: {
							"qwen3.5-9b":           {name: "qwen3.5-9b"}
							"cyber-tiel-coder-35b": {name: "cyber-tiel-coder-35b"}
							"bonsai-2-27b":         {name: "bonsai-2-27b"}
						}
					}
				}
			}
		}
	}
