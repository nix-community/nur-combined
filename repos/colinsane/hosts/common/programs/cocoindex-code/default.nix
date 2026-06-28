{ ... }:
{
  sane.programs.cocoindex-code = {
    sandbox.whitelistPwd = true;
    sandbox.net = "clearnet";  # for model downloads
    # persist.byStore.private = [
    #   ".cocoindex_code"
    # ];
    fs.".cocoindex_code/global_settings.yml".symlink.text = ''
      # CocoIndex Code - global settings.
      # After editing this file, run `ccc doctor` to verify your configuration.

      embedding:
        provider: sentence-transformers
        model: Snowflake/snowflake-arctic-embed-xs
        indexing_params: {}
        query_params:
          prompt_name: query

      # Environment variables to inject into the daemon running in the background.
      # Uncomment and fill in keys for the LiteLLM providers you plan to use.
      #
      # envs:
      #   OPENAI_API_KEY: ...
      #   GEMINI_API_KEY: ...
      #   ANTHROPIC_API_KEY: ...
      #   VOYAGE_API_KEY: ...
    '';
  };
}
