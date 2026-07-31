{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "bugjour";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "bugjour";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WtUiDry2ctStzvLi8InBckewjpuhYV3/J3PRqLzfp6c=";
  };

  vendorHash = "sha256-4V3cIgEN8WkHHrPz9SRshoiu0C+NHR0Xov1FZ06Q9XI=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    help =
      runCommand "test-bugjour-help"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          bugjour --help
          touch $out
        '';
  };

  meta = {
    description = "Detect Apple Bonjour hostname conflicts";
    homepage = "https://github.com/josh/bugjour";
    license = lib.licenses.mit;
    mainProgram = "bugjour";
  };
})
