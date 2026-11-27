{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "spilltea";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "spilltea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VN0tEiY89UIGXsiB3p882vKiNlV7nCg1w+8pjZ1iG/M=";
  };

  vendorHash = "sha256-qJuQs4awf6eKL1i1mpeJiHrma9x19VivC9KAqe/l24s=";

  subPackages = ["cmd/spilltea"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/anotherhadi/spilltea/internal/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/spilltea";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI intercepting proxy for pentesters and bug bounty hunters, a lightweight terminal-first alternative to Burp Suite and Caido";
    homepage = "https://github.com/anotherhadi/spilltea";
    changelog = "https://github.com/anotherhadi/spilltea/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "spilltea";
  };
})
