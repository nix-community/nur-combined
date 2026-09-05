package module

module: {
	meta: {
		requires: []
		recommends: []
	}
	config: {}
	file: {
		".config/opencode/opencode.json": {
			type: "json"
			values: {
				"$schema": "https://opencode.ai/config.json"
				theme:     "workspaced"
				plugin: ["opencode-gemini-auth"]
				provider: {
					llamacpp: {
						npm:  "@ai-sdk/openai-compatible"
						name: "llama.cpp"
						options: {baseURL: "http://whiterun:38286/v1"}
						models: {
							"qwen3.5-9b": {name: "qwen3.5-9b"}
						}
					}
				}
			}
		}
	}
}
