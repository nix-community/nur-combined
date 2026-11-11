{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "spilltea";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "spilltea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nlkYqSGzmVPJcQQf0QCmjqEmkxFL3kzOteAUliEIFBg=";
  };

  vendorHash = "sha256-fQb/a7SXl8rf0vkCMLcQzSZ/BhduPXEKGYNrvrkRKJY=";

  subPackages = ["cmd/spilltea"];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sectui/spilltea/internal/config.Version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/spilltea";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI intercepting proxy for pentesters and bug bounty hunters, a lightweight terminal-first alternative to Burp Suite and Caido";
    homepage = "https://github.com/sectui/spilltea";
    changelog = "https://github.com/sectui/spilltea/releases/tag/v${finalAttrs.version}";
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
