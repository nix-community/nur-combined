{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "gwq";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "d-kuro";
    repo = "gwq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oSgDH5E3ETSlpovhU+MNmDTpY2BRGsR9Bf57ot04Rng=";
  };

  vendorHash = "sha256-jP4arRoTDcjRXZvLx7R/1pp5gRMpfZa7AAJDV+WLGhY=";

  subPackages = ["cmd/gwq"];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Git worktree manager CLI tool with fuzzy finder support";
    longDescription = ''
      gwq is a Git worktree manager that provides intuitive operations for
      creating, switching, and deleting worktrees. Like how ghq manages
      repository clones, gwq provides similar functionality for worktrees,
      enabling parallel development workflows.
    '';
    homepage = "https://github.com/d-kuro/gwq";
    license = lib.licenses.asl20;
    maintainers = [];
    mainProgram = "gwq";
  };
})
