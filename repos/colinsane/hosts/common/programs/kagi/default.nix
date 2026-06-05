{ pkgs, ... }:
{
  sane.programs.kagi = {
    packageUnwrapped = pkgs.kagi.overrideAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.makeShellWrapper
      ];
      postInstall = ''
        wrapProgramShell $out/bin/kagi \
          --run 'if [[ -z "''${KAGI_API_KEY:-}" ]]; then export KAGI_API_KEY=$(cat ~/.config/kagi/kagi-api-key); fi'
      '';
    });

    sandbox.net = "all";
    secrets.".config/kagi/kagi-api-key" = ../../../../secrets/common/kagi-api-key.bin;
  };
}
