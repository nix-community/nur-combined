{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
let
  caddy-tailscale = buildGoModule {
    pname = "caddy-tailscale";
    version = "0-unstable-2025-05-08";

    src = fetchFromGitHub {
      owner = "tailscale";
      repo = "caddy-tailscale";
      rev = "642f61fea3ccc6b04caf381e2f3bc945aa6af9cc";
      hash = "sha256-oVywoZH7+FcBPP1l+kKjh+deiI6+H/N//phAuiSC4tc=";
    };

    vendorHash = "sha256-eed3AuRhRO66xFg+447xLv7otAHbzAUuhxMcNugZMOA=";

    env.CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
    ];

    preCheck = ''
      export HOME=$(mktemp -d)
    '';

    meta = {
      description = "A highly experimental exploration of integrating Tailscale and Caddy";
      homepage = "https://github.com/tailscale/caddy-tailscale";
      license = lib.licenses.mit;
      mainProgram = "caddy";
      platforms = lib.platforms.all;
    };
  };
in
caddy-tailscale.overrideAttrs (
  finalAttrs: _previousAttrs:
  let
    caddy-tailscale = finalAttrs.finalPackage;
  in
  {
    passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

    passthru.tests = {
      build-info = runCommand "test-caddy-build-info" { nativeBuildInputs = [ caddy-tailscale ]; } ''
        caddy build-info | grep "github.com/tailscale/caddy-tailscale"
        touch $out
      '';
    };
  }
)
