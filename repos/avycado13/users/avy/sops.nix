{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    atuin-session = {
      path = "${config.home.homeDirectory}/.local/share/atuin/session";
      mode = "0444";
    };
    atuin-key = {
      path = "${config.home.homeDirectory}/.local/share/atuin/key";
      mode = "0444";
    };
    slack_user_id = { };
    context7_api_key = { };
    gh_mcp_token = { };
    chroma_mcp_token = { };
    icloud_email_password = { };
    soju_password = { };
    syncthing-guipass = {
      sopsFile = ../../secrets/services.yaml;
      key = "syncthing/guipass";
      path =
        if pkgs.stdenv.hostPlatform.isLinux then
          "${config.home.homeDirectory}/.local/state/syncthing/guiPass"
        else
          "${config.home.homeDirectory}/.config/syncthing/guiPass";
      mode = "0400";
    };
    niks3_api_token = {
      sopsFile = ../../secrets/services.yaml;
      key = "niks3/api_token";
      mode = "0400";
    };
  };

}
