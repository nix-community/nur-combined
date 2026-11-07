{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "revdiff";
  version = "1.14.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x0pst0Rlu4+43gb7EPzl6bjXO5+QqWP9EBbD+QJzEO0=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-X main.revision=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    installShellCompletion completions/*
  '';

  meta = {
    description = "TUI for reviewing git diffs with inline annotations";
    homepage = "https://github.com/umputun/revdiff";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "revdiff";
  };
})
