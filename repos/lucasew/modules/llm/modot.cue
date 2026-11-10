package module

options: {}

// simonw/llm talking to the aperture OpenAI-compatible gateway.
// The shim (bin/shim/llm) runs the CLI via uvx; these files only configure it.
file: home: {
	".config/io.datasette.llm/extra-openai-models.yaml": {
		type: "text"
		values: {
			content: """
				- model_id: deepseek_coding_flash
				  model_name: deepseek_coding_flash
				  api_base: https://ai.stargazer-shark.ts.net/v1
				  headers:
				    x-opencode-session: llm-aperture
				  supports_tools: true
				""" + "\n"
		}
	}
	".config/io.datasette.llm/default_model.txt": {
		type: "text"
		values: {
			content: "deepseek_coding_flash\n"
		}
	}
}
