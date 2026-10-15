{ pkgs, config, ... }:
{
  sops.secrets.gemini_api_key = { };
  sops.secrets.opencode_api_key = { };
  programs.opencode = {
    enable = true;
    skills.find-flake-input = ./skills/find-flake-input;
    skills.grilling = pkgs.agent-skills.github.mattpocock.skills.grilling;
    skills.i-have-adhd = pkgs.agent-skills.github.ayghri.i-have-adhd.i-have-adhd;
    skills.ponytail = pkgs.agent-skills.github.dietrichgebert.ponytail.ponytail;
    skills.ponytail-review = pkgs.agent-skills.github.dietrichgebert.ponytail.ponytail-review;
    skills.skill-creator = ./skills/skill-creator;
    extraPackages = with pkgs; [ rtk ];
    settings = {
      small_model = "google/gemini-3.5-flash-lite";
      plugin = [
        "${pkgs.rtk.src}/hooks/opencode/rtk.ts"
      ];
      provider = {
        google.options.apiKey = "{file:${config.sops.secrets.gemini_api_key.path}}";
        opencode.options.apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
        "llama.cpp" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-server (local)";
          options.baseURL = "http://127.0.0.1:8080/v1";
          models = {
            "preset/Ornith-1.5-35B-A3B" = {
              name = "Ornith-1.5-35B-A3B (local)";
              limit = {
                context = 131072;
                output = 65536;
              };
              attachment = true;
              family = "qwen";
              modalities = {
                input = [
                  "text"
                  "image"
                  "video"
                ];
                output = [ "text" ];
              };
              open_weights = true;
              reasoning = true;
              reasoning_options = [ ];
              structured_output = true;
              temperature = true;
              tool_call = true;
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
