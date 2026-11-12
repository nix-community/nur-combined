{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "spilltea";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "spilltea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cNTZG3jevJeRcdaqJghnroq05T1CSOxBDEi5Hj5qcew=";
  };

  vendorHash = "sha256-u+u38Qr5Dugk5eFmxTK4vKUEv2SlXcfY6ZFlu1cPqVk=";

  subPackages = ["cmd/spilltea"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
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
