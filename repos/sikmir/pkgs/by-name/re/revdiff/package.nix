{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "revdiff";
  version = "1.15.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "revdiff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5KJ8q4cDLiFP64iCAt5NvJ9lm4zF9R9snGRiOtxEGis=";
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
