{
  cacert,
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  tzdata,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clickup-cli";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "nicholasbester";
    repo = "clickup-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pK3AIiHYvl8kB05VHbukJ7i8ZSX9Qj2o055cvtdouAI=";
  };

  cargoHash = "sha256-FmIdG3gDWG7RQg5fY2rL6RgHtX8DXWdaYgI5fQZB64g=";

  nativeCheckInputs = [ gitMinimal ];

  # tests/test_due_date.rs runs the binary with TZ=America/New_York; chrono
  # only resolves that via /usr/share/zoneinfo (absent in the sandbox) or an
  # absolute TZ path, so point it at tzdata directly.
  postPatch = ''
    substituteInPlace tests/test_due_date.rs \
      --replace-fail '"America/New_York"' '"${tzdata}/share/zoneinfo/America/New_York"'
  '';

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "CLI for the ClickUp API, optimized for AI agents";
    homepage = "https://clickup-cli.com/";
    changelog = "https://github.com/nicholasbester/clickup-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "clickup-cli";
  };
})
