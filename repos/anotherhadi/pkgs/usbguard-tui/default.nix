{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "usbguard-tui";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "usbguard-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EkexDNQStKryIcdofI5y0eoXJ9eEWFO/WA+vl9f+Tpc=";
  };

  vendorHash = "sha256-2HDqIR+9nA3HKKpuPUD7uX4FiMTTiQOfKw06ZxypPk8=";

  subPackages = ["cmd/usbguard-tui"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/usbguard-tui";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI for managing USB devices via usbguard";
    homepage = "https://github.com/anotherhadi/usbguard-tui";
    changelog = "https://github.com/anotherhadi/usbguard-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "usbguard-tui";
  };
})
