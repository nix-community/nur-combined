{ pkgs, ... }:
{
  sane.programs.kagimcp = {
    packageUnwrapped = pkgs.kagimcp.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.makeWrapper
      ];
      postFixup = upstream.postFixup or "" + ''
        wrapProgram $out/bin/kagimcp \
          --run 'export KAGI_API_KEY=''${KAGI_API_KEY:-$(cat "$XDG_CONFIG_HOME/kagi/kagi-api-key")}'
      '';
    });

    sandbox.net = "clearnet";
    secrets.".config/kagi/kagi-api-key" = ../../../../secrets/common/kagi-api-key.bin;
  };
}
