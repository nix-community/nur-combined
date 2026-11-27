{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "spilltea";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "spilltea";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uvNR5kwCIJPRolGFgFwvcGk/+FDE+6s5LFmjLYf9Kpc=";
  };

  vendorHash = "sha256-sU2Z6U2v/Qz6YLPEN5dPPmlXwLXRnpE6aSMnh+GTMSI=";

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
