{ config, pkgs, ... }:
{
  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      continue.continue
    ];
    profiles.default.userSettings = {
      "yaml.schemas" = {
        "file://${config.home.homeDirectory}/.vscode/extensions/Continue.continue/config-yaml-schema.json" = [
          ".continue/**/*.yaml"
        ];
      };
    };
  };
  programs.fish = {
    shellAliases = {
      cn = "${pkgs.nur.repos.MiyakoMeow.continue-cli}/bin/cn --config ${config.xdg.configHome}/continue/config.yaml";
    };
  };
  home.sessionVariables = {
    CONTINUE_GLOBAL_DIR = "${config.xdg.configHome}/continue";
  };
  xdg.configFile."continue/config.yaml".text = builtins.toJSON {
    name = "Local Agent";
    version = "1.0.0";
    schema = "v1";
    models =
      let
        mkModel = { name, provider ? "openai", model ? name, apiBase, roles }: {
          inherit name provider model apiBase roles;
          apiKey = "dummy";
        };
        litellm = "http://localhost:4000/v1";
        llama-cpp = "http://localhost:8080/v1";
      in
      [
        (mkModel { name = "mimo-v2.5-pro"; apiBase = litellm; roles = [ "chat" "edit" ]; })
        (mkModel { name = "gemini-chat"; apiBase = litellm; roles = [ "chat" "edit" ]; })
        (mkModel { name = "Qwen3.6-35B-A3B-MTP"; apiBase = llama-cpp; roles = [ "chat" "edit" ]; })
        (mkModel { name = "Qwen2.5-Coder-1.5B-CodeFIM"; apiBase = llama-cpp; roles = [ "autocomplete" ]; })
        (mkModel { name = "FastApply-1.5B-v1.0"; apiBase = llama-cpp; roles = [ "apply" ]; })
        (mkModel { name = "gemini-embedding"; apiBase = litellm; roles = [ "embed" ]; })
        (mkModel { name = "nomic-embed-text-v1.5"; apiBase = llama-cpp; roles = [ "embed" ]; })
        (mkModel { name = "zerank-1-small"; apiBase = llama-cpp; roles = [ "rerank" ]; })
      ];
  };
}
