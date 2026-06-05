{ pkgs, ... }:
{
  sane.programs.github-mcp-server = {
    packageUnwrapped = pkgs.github-mcp-server.overrideAttrs (prevAttrs: {
      nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [
        pkgs.makeWrapper
      ];

      postFixup = prevAttrs.postFixup or "" + ''
        wrapProgram $out/bin/github-mcp-server \
          --run 'export GITHUB_PERSONAL_ACCESS_TOKEN=''${GITHUB_PERSONAL_ACCESS_TOKEN:-$(cat "$XDG_CONFIG_HOME/github-mcp-server/access_token")}'
      '';
    });
    sandbox.net = "clearnet";
    secrets.".config/github-mcp-server/access_token" = ../../../../secrets/common/github_mcp_server_access_token.bin;
  };
}
