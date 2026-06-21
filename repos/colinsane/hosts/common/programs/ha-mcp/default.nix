{ pkgs, ... }:
{
  sane.programs.ha-mcp = {
    packageUnwrapped = pkgs.ha-mcp.overrideAttrs (prevAttrs: {
      nativeBuildInputs = (prevAttrs.nativeBuildInputs or []) ++ [
        pkgs.makeWrapper
      ];
      postFixup = prevAttrs.postFixup or "" + ''
        wrapProgram $out/bin/ha-mcp \
          --run 'export HAMCP_ENV_FILE=''${HAMCP_ENV_FILE:-$XDG_CONFIG_HOME/ha-mcp/ha-mcp.env}'
      '';
    });

    sandbox.net = "all";
    secrets.".config/ha-mcp/ha-mcp.env" = ../../../../secrets/common/ha-mcp.env.bin;
  };
}
