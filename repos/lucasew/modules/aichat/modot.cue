package module

options: {}

// aichat reads its config from dirs::config_dir()/aichat: ~/.config on Linux,
// ~/Library/Application Support on macOS. Follow that so no shell env is
// needed (the previous AICHAT_CONFIG_DIR export never reached zsh).
//
// aichat talks to the aperture OpenAI-compatible gateway, which wants an
// x-opencode-session header, patched in for every chat completion.
let config = {
	type: "text"
	values: {
		content: """
			clients:
			  - type: openai-compatible
			    name: aperture
			    api_base: https://ai.stargazer-shark.ts.net/v1
			    api_key: unused
			    models:
			      - name: deepseek_coding_flash
			        supports_function_calling: true
			    patch:
			      chat_completions:
			        '.*':
			          headers:
			            x-opencode-session: aichat-aperture
			default_model: aperture:deepseek_coding_flash
			""" + "\n"
	}
}

file: home: {
	if runtime.goos == "darwin" {
		"Library/Application Support/aichat/config.yaml": config
	}
	if runtime.goos != "darwin" {
		".config/aichat/config.yaml": config
	}
}
