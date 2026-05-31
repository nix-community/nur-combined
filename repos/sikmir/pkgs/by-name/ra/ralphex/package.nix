{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "ralphex";
  version = "1.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "ralphex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bL1RFGL7+ceDgDOgKw1pBZGKjtj1WrtxAoFRuByuUS4=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.revision=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    git
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    installShellCompletion completions/*
  '';

  meta = {
    description = "Extended Ralph loop for autonomous AI-driven plan execution";
    homepage = "https://ralphex.com/";
    license = lib.licenses.mit;
    mainProgram = "ralphex";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
