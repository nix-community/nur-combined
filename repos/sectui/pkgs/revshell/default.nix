{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "revshell";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "revshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W+luu6TcsDIYUN9jOqcU00pg7J5aOsx5grk7JCQE0Hg=";
  };

  vendorHash = "sha256-GaJzDv5fuB9p9Mh8vR5vlBIOpS/grvzKIZM8lDpzeiM=";

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
    homepage = "https://github.com/sectui/revshell";
    changelog = "https://github.com/sectui/revshell/releases/tag/v${finalAttrs.version}";
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
