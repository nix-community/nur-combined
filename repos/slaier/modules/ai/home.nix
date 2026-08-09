{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./claude-code/home.nix
  ];

  home.packages = with pkgs; [
    geminicommit
  ];

  sops.secrets = {
    tavily = { };
    github = { };
  };
  programs.mcp = {
    enable = true;
    servers =
      let
        mcp-remote =
          flags:
          "${lib.getExe (
            pkgs.writeShellApplication {
              name = "mcp-remote";
              runtimeInputs = [ pkgs.nodejs ];
              text = ''
                npx -y mcp-remote ${flags}
              '';
            }
          )}";
      in
      {
        tavily = {
          enabled = true;
          env.TAVILY_API_KEY.file = config.sops.secrets.tavily.path;
          command = mcp-remote ''"https://mcp.tavily.com/mcp/?tavilyApiKey=$TAVILY_API_KEY"'';
        };
        github = {
          enable = true;
          env.GITHUB_PERSONAL_ACCESS_TOKEN.file = config.sops.secrets.github.path;
          command = "${lib.getExe pkgs.github-mcp-server}";
          args = [
            "stdio"
            "--tools"
            (lib.concatStringsSep "," [
              "get_file_contents"
              "get_repository_tree"
              "list_tags"
              "search_code"
            ])
          ];
        };
        nixos = {
          enable = true;
          command = lib.getExe pkgs.mcp-nixos;
        };
      };
  };
}
