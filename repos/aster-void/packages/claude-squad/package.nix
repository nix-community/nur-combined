{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "claude-squad";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "smtg-ai";
    repo = "claude-squad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OL+IG+NvrwAc0+7BlKJPKdSx8ZIbI/FtdvlAA807NYI=";
  };

  vendorHash = "sha256-BduH6Vu+p5iFe1N5svZRsb9QuFlhf7usBjMsOtRn2nQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = {
    description = "Manage multiple AI code assistants with tmux and git worktrees";
    homepage = "https://github.com/smtg-ai/claude-squad";
    license = lib.licenses.asl20;
    maintainers = [];
    mainProgram = "claude-squad";
  };
})
