{
  lib,
  stdenv,
  buildGo127Module,
  fetchFromGitHub,

  go_1_27,

  nix-update-script,
  testers,
}:
buildGo127Module (finalAttrs: {
  pname = "execonnect";
  version = "0.12.930775705";

  src = fetchFromGitHub {
    owner = "boldsoftware";
    repo = "exe.dev";
    tag = "execonnect/v${finalAttrs.version}";
    hash = "sha256-NFZ+A6eRZzPdC5JklIzYWYTo2DnvYzK7Y7gxIzkG4qs=";
  };

  sourceRoot = "${finalAttrs.src.name}/execonnect";

  vendorHash = "sha256-9SkjLWayduBWg9ZFwyQp1GJaRyLhH4+wK/b+OnjWe9o=";

  env.CGO_ENABLED = 0;
  subPackages = [ "cmd/execonnect" ];
  ldflags = [
    "-s"
    "-w"
    "-X github.com/boldsoftware/exe.dev/execonnect.Version=${finalAttrs.version}"
  ];

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-skip=^(TestDaemonFirstCLIAndTerminalAuthFailure|TestEnrollmentRejectionLeavesDaemonUnenrolled)$"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=execonnect/v(.*)" ];
  };

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Connect private HTTP services to exe.dev VMs";
    homepage = "https://exe.dev/docs/integrations-external-connections";
    license = lib.licenses.asl20;
    mainProgram = "execonnect";
    broken = lib.versionOlder go_1_27.version "1.27.3";
  };
})
