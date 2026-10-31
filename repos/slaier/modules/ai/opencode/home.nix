{ pkgs, config, ... }:
{
  sops.secrets.gemini_api_key = { };
  sops.secrets.opencode_api_key = { };
  home.packages = with pkgs; [ nur.repos.natsukium.playwright-cli ];
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
    extraPackages = with pkgs; [ rtk ];
    settings = {
      small_model = "google/gemini-3.5-flash-lite";
      plugin = [
        "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
      ];
      providers = {
        google.settings.apiKey = "{file:${config.sops.secrets.gemini_api_key.path}}";
        opencode.settings.apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
        "llama.cpp" = {
          name = "llama-server (local)";
          package = "@opencode/ai/providers/openai-compatible";
          settings.baseURL = "http://127.0.0.1:8080/v1";
          models = {
            "InternScience/Sage-A1.5" = {
              name = "Sage-A1.5 (local)";
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
                temperature = true;
                tools = true;
              };
              limit.context = 131072;
            };
            "XHToken/Spark-X2.6-4B" = {
              name = "Spark-X2.6-4B (local)";
              capabilities = {
                input = [ "text" ];
                output = [ "text" ];
                reasoning = {
                  supported = true;
                  effort = [
                    "low"
                    "high"
                  ];
                };
                temperature = true;
                tools = true;
              };
              limit.context = 131072;
            };
          };
        };
      };
      permission = {
        read = {
          "secrets/**" = "deny";
        };
      };
    };
  };
}
