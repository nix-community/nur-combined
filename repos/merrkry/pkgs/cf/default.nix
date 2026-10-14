{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_12,
  pnpmConfigHook,
  nodejs,
  makeWrapper,
  autoPatchelfHook,
  patchelfUnstable,
  nix-update-script,
  versionCheckHook,
  disableTelemetry ? true,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "cf";
  version = "1.0.0-beta.16";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf";
    tag = "cf@${finalAttrs.version}";
    hash = "sha256-qpLkA4mR2unBUSPvCi9g1VXbS/GvnsQdt+IFx9PG6mk=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash = "sha256-NdjMAECy0/L/CEHHULi1qfZ0BduIJbu6HsL5UW9TCqw=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    pnpm_12
    pnpmConfigHook
    nodejs
    makeWrapper
    autoPatchelfHook
    patchelfUnstable
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  # Preserve libvips' .init code: moving it can leave DT_INIT pointing at the
  # old address, causing a crash when the library loads.
  # https://github.com/NixOS/patchelf/issues/639
  patchelfFlags = [ "--no-clobber-old-sections" ];

  buildPhase = ''
    runHook preBuild

    # Release tags already contain the generated API commands and metadata.
    pnpm --filter cf exec vp pack

    runHook postBuild
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    # The tests create executable scripts from these embedded shebangs.
    while IFS= read -r -d "" testFile; do
      substituteInPlace "$testFile" \
        --replace-quiet '#!/usr/bin/env node' '#!${lib.getExe nodejs}'
    done < <(find packages/cli/src/__tests__ -name '*.ts' -print0)

    autoPatchelf node_modules
    pnpm --filter cf exec vp test run

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    pnpm --offline --ignore-scripts --filter cf --prod \
      --config.inject-workspace-packages=true deploy "$out/lib/node_modules/cf"
    makeWrapper ${lib.getExe nodejs} "$out/bin/cf" \
      --add-flags "$out/lib/node_modules/cf/bin/cf" \
      ${lib.optionalString disableTelemetry "--set CF_SEND_TELEMETRY false"}
    ln -s cf "$out/bin/cloudflare"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postInstallCheck = ''
    CF_TEST_PACKAGE="$out" \
    CF_TEST_EXPECT_TELEMETRY="${if disableTelemetry then "Disabled" else "Enabled"}" \
      node --test ${./tests.mjs}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=unstable"
      "--version-regex=cf@(.*)"
    ];
  };

  meta = {
    description = "Agentic CLI for the entire Cloudflare API";
    homepage = "https://github.com/cloudflare/cf";
    changelog = "https://github.com/cloudflare/cf/releases/tag/cf@${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "cf";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
