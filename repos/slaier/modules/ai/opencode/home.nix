{ pkgs, config, ... }:
{
  sops.secrets.gemini_api_key = { };
  sops.secrets.opencode_api_key = { };
  home.packages = with pkgs; [
    nur.repos.natsukium.playwright-cli
    rtk
  ];
  programs.opencode = {
    enable = true;
    skills.find-flake-input = ./skills/find-flake-input;
    skills.grilling = pkgs.agent-skills.github.mattpocock.skills.grilling;
    skills.i-have-adhd = pkgs.agent-skills.github.ayghri.i-have-adhd.i-have-adhd;
    skills.playwright-cli = pkgs.agent-skills.github.microsoft.playwright-cli.playwright-cli;
    skills.ponytail = pkgs.agent-skills.github.dietrichgebert.ponytail.ponytail;
    skills.ponytail-review = pkgs.agent-skills.github.dietrichgebert.ponytail.ponytail-review;
    skills.ponytail-simplify = ./skills/ponytail-simplify;
    skills.skill-creator = ./skills/skill-creator;
    settings = {
      small_model = "google/gemini-3.5-flash-lite";
      providers = {
        google.settings.apiKey = "{file:${config.sops.secrets.gemini_api_key.path}}";
        opencode.settings.apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
        "llama.cpp" = {
          name = "llama-server (local)";
          package = "@opencode/ai/providers/openai-compatible";
          settings.baseURL = "http://127.0.0.1:8080/v1";
          models = {
            "ornith-ai/Ornith-1.5-35B-A3B" = {
              name = "Ornith-1.5-35B-A3B (local)";
              capabilities = {
                input = [
                  "text"
                  "image"
                  "video"
                ];
                output = [ "text" ];
                reasoning = {
                  supported = true;
                  effort = [ "max" ];
                };
                tools = true;
              };
              limit.context = 262144;
            };
          };
        };
      };
    };
  };
  xdg.configFile."opencode/plugins/rtk.ts".source = "${pkgs.rtk.src}/hooks/opencode/rtk.ts";
}
