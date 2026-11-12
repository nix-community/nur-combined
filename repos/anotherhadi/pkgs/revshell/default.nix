{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "revshell";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "revshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+g/AeHHQdNMYMlYrYf/+qd0cCtSOJiEfxIXddJzxy8E=";
  };

  vendorHash = "sha256-X2AtAGIpnnXf319QgUyiScIgliA0iN3B2ftf59QIeWI=";

  subPackages = ["cmd/revshell"];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/revshell";
  versionCheckProgramArg = "--version";

  meta = {
    description = "TUI to search, render and copy reverse shell one-liners: bind shells, MSFVenom, HoaxShell and shellcode included, with a scriptable CLI";
    homepage = "https://github.com/anotherhadi/revshell";
    changelog = "https://github.com/anotherhadi/revshell/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "revshell";
  };
})
