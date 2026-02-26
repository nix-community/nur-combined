{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zed;
  baseSettings = builtins.fromJSON (builtins.readFile ./zed-settings.json);
  settingsWithSecrets = baseSettings // {
    context_servers = (baseSettings.context_servers or { }) // {
      "mcp-server-brave-search" = {
        enabled = true;
        remote = false;
        settings = {
          brave_api_key = config.sops.placeholder.brave_api_key;
        };
      };
      "mcp-server-github" = {
        enabled = true;
        remote = false;
        settings = {
          github_personal_access_token = config.sops.placeholder.${cfg.githubPatSecret};
        };
      };
    };
  };
in
{
  options.programs.zed = {
    enable = lib.mkEnableOption "enable zed";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zed-editor;
    };
    githubPatSecret = lib.mkOption {
      type = lib.types.str;
      default = "github_toyvo_pat";
      description = "Name of the sops secret containing the GitHub PAT for Zed.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.brave_api_key = { };
    sops.secrets.${cfg.githubPatSecret} = { };

    sops.templates."zed-settings" = {
      content = builtins.toJSON settingsWithSecrets;
      path = "${config.xdg.configHome}/zed/settings.json";
      mode = "0600";
    };

    home.packages = [ cfg.package ];
  };
}
