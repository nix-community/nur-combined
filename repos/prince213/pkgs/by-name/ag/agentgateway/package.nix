{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  rustPlatform,

  # nativeBuildInputs
  pkg-config,
  pnpm_11,
  pnpmConfigHook,

  # buildInputs
  aws-lc,
  rust-jemalloc-sys-unprefixed,
  sqlite,
  zstd,

  # nativeCheckInputs
  cacert,

  # nativeInstallCheckInputs
  versionCheckHook,
}:
let
  pnpm = pnpm_11;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agentgateway";
  version = "1.7.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "agentgateway";
    repo = "agentgateway";
    tag = "v${finalAttrs.version}";
    hash = "sha256-otrX0zLcDb/QPrErHmvW4eihsV1WEcnsE1jFlnp1pwI=";
  };

  cargoHash = "sha256-tcF+rj+WPUwil+kQA1dbkLK/ybLt0CJTGi7qmeMyo94=";

  postPatch = ''
    patchShebangs tools/report_build_info.sh
  '';

  preBuild = ''
    ln -s ${finalAttrs.passthru.ui} ui/dist
  '';

  env.VERSION = finalAttrs.version;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    aws-lc
    rust-jemalloc-sys-unprefixed
    sqlite
    zstd
  ];

  buildFeatures = [ "ui" ];

  preCheck = ''
    unset RUST_LOG
  '';

  dontUseCargoParallelTests = true;
  nativeCheckInputs = [ cacert ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    ui = buildNpmPackage (finalAttrs': {
      pname = finalAttrs.pname + "-ui";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;

      sourceRoot = "${finalAttrs'.src.name}/ui";

      npmDeps = null;
      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs')
          pname
          version
          src
          sourceRoot
          ;
        inherit pnpm;
        fetcherVersion = 5;
        hash = "sha256-cT4u/PhsURhtOjirDXR9MhUJTcT9O5BUPsmUPHm49yI=";
      };

      nativeBuildInputs = [ pnpm ];
      npmConfigHook = pnpmConfigHook;

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r dist/. $out

        runHook postInstall
      '';
    });
  };

  meta = {
    description = "Proxy for AI agents and MCP servers";
    homepage = "https://agentgateway.dev/";
    downloadPage = "https://github.com/agentgateway/agentgateway/releases";
    changelog = "https://github.com/agentgateway/agentgateway/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "agentgateway";
  };
})
