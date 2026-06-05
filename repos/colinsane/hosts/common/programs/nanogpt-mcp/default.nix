{ pkgs, ... }:
{
  sane.programs.nanogpt-mcp = {
    packageUnwrapped = pkgs.nanogpt-mcp.overrideAttrs (prevAttrs: {
      nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ [
        pkgs.makeWrapper
      ];
      postFixup = prevAttrs.postFixup or "" + ''
        wrapProgram $out/bin/nanogpt-mcp \
          --run 'export NANOGPT_API_KEY=''${NANOGPT_API_KEY:-$(cat "$XDG_CONFIG_HOME/nanogpt/nanogpt_api_key")}'
      '';
    });
    sandbox.net = "clearnet";

    secrets.".config/nanogpt/nanogpt_api_key" = ../../../../secrets/common/nanogpt_api_key.bin;
  };
}
