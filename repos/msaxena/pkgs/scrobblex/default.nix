{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  testers,
}:

buildNpmPackage (finalAttrs: {
  pname = "scrobblex";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "ryck";
    repo = "scrobblex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rNtuditjzCdpBUnheM/Y+88cB8b/PZKF5U2Bczo1vdw=";
  };

  npmDepsHash = "sha256-2kgqQr0oiCIcUEkvnqDsmlKK9UdDKYxtLYDJ9+gMkNA=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/scrobblex
    cp -r src views static favicon.ico package.json node_modules $out/lib/scrobblex/

    makeWrapper ${lib.getExe nodejs} $out/bin/scrobblex \
      --add-flags "$out/lib/scrobblex/src/index.js" \
      --chdir "$out/lib/scrobblex"

    runHook postInstall
  '';

  passthru.tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    scrobblex = testers.nixosTest {
      name = "scrobblex";

      nodes.machine =
        { pkgs, ... }:
        {
          imports = [ ../../nixos-modules/scrobblex.nix ];

          services.scrobblex = {
            enable = true;
            port = 3090;
            package = finalAttrs.finalPackage;
            # Provide dummy credentials via an environment file so the service
            # starts without network access.  The OAuth flow will not work with
            # these values, but the /healthcheck endpoint does not require it.
            environmentFile = pkgs.writeText "scrobblex-env" ''
              TRAKT_ID=test-client-id
              TRAKT_SECRET=test-client-secret
            '';
          };
        };

      testScript = ''
        machine.wait_for_unit("scrobblex.service")
        machine.wait_for_open_port(3090)
        response = machine.succeed("curl -sf http://localhost:3090/healthcheck")
        import json
        data = json.loads(response)
        assert data["message"] == "OK", f"unexpected healthcheck response: {data}"
      '';
    };
  };

  meta = {
    description = "Self-hosted Plex scrobbling integration with Trakt via webhooks";
    longDescription = ''
      Scrobblex is a self-hosted Node.js application that listens for Plex (or
      Tautulli) webhooks and scrobbles your watched media to Trakt. It also
      supports pushing Plex ratings back to Trakt.
    '';
    homepage = "https://github.com/ryck/scrobblex";
    license = lib.licenses.mit;
    mainProgram = "scrobblex";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
