{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.promptbox ];

  xdg.configFile."promptbox/.env".text = "OMNIROUTE_API_KEY=sk-632ab2d295d5b3f7-47e716-45028b44";

  xdg.configFile."promptbox/promptbox.toml".source = pkgs.writers.writeTOML "promptbox.toml" {
    templates = [ ./templates ];
    model = {
      model = {
        model = "anthropic/claude-haiku";
        host = "omniroute";
      };
      context = {
        limit = 131072;
        reserve_output = 8192;
        trim_args = [ ];
      };
    };
    host.omniroute = {
      endpoint = "http://127.0.0.1:20128/v1";
      protocol = "openai";
      limit_context_length = false;
      api_key = "OMNIROUTE_API_KEY";
      send_app_id = false;
    };
  };

  programs.fish.functions = {
    aic = ''
      begin
        git diff --cached --name-status
        git diff --cached -O (git diff --cached --name-only --diff-filter ad | psub)
      end | proxychains4 -q promptbox run commit | xargs -p -r -0 -I{} git commit -m '{}'
    '';

    tzh = "xargs -p -r -0 proxychains4 -q promptbox run translate --target_lang zh";
    ten = "xargs -p -r -0 proxychains4 -q promptbox run translate --target_lang en";
  };
}
