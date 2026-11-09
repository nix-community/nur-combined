package module

options: {}

file: home: {
		".config/opencode/opencode.json": {
			type: "json"
			values: {
				"$schema": "https://opencode.ai/config.json"
				theme:     "modot"
				model: "aperture/deepseek-v4.1-flash-1017"
				plugin: ["opencode-gemini-auth"]
				provider: {
					aperture: {
						npm:  "@ai-sdk/openai-compatible"
						name: "Aperture"
						options: {baseURL: "https://ai.stargazer-shark.ts.net/v1"}
						models: {
							for _, model in ["qwen3.5-9b", "cyber-tiel-coder-35b", "bonsai-2-27b", "deepseek-v4.1-flash-1017"] {
								"\(model)": { name: model }
							}
						}
						
					}
					// cheaperinference: {
					// 	npm:  "@ai-sdk/openai-compatible"
					// 	name: "CheaperInference",
					// 	options: {baseURL: "https://api.cheaperinference.com/v1"}
					// 	models: {
					// 		"deepseek-v4.1-flash-1017": {name: "deepseek-v4.1-flash-1017"}
					// 	}
					// }
					// llamacpp: {
					// 	npm:  "@ai-sdk/openai-compatible"
					// 	name: "llama.cpp"
					// 	options: {baseURL: "http://whiterun:38286/v1"}
					// 	models: {
					// 		"qwen3.5-9b":           {name: "qwen3.5-9b"}
					// 		"cyber-tiel-coder-35b": {name: "cyber-tiel-coder-35b"}
					// 		"bonsai-2-27b":         {name: "bonsai-2-27b"}
					// 	}
					// }
				}
			}
		}
	}
