{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

let
  version = "0.19.0";
in

buildGoModule {
  pname = "woke";
  inherit version;

  src = fetchFromGitHub {
    owner = "get-woke";
    repo = "woke";
    rev = "refs/tags/v${version}";
    hash = "sha256-X9fhExHhOLjPfpwrYPMqTJkgQL2ruHCGEocEoU7m6fM=";
  };

  vendorHash = "sha256-lRUvoCiE6AkYnyOCzev1o93OhXjJjBwEpT94JTbIeE8=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/get-woke/woke/cmd.Version=${version}"
  ];

  checkFlags =
    let
      skipTests = [
        # Requires network access
        "TestNewConfig/load-config-with-url"
        "TestNewConfig/load-remote-config-valid-url"

        # Requires Git
        "TestIgnoreTestSuite/TestGetRootGitDir"
      ];
    in
    [ ("-skip=" + builtins.concatStringsSep "|" skipTests) ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "woke";
    description = "Detect non-inclusive language in your source code";
    homepage = "https://github.com/get-woke/woke";
    changelog = "https://github.com/get-woke/woke/releases/tag/v${version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
