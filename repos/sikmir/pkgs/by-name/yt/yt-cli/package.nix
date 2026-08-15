{
  stdenv,
  lib,
  fetchFromGitHub,
  python3Packages,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "yt-cli";
  version = "0.25.1";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ryancheley";
    repo = "yt-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-niOyM9VQ+xHddOiI0U60m5zDYlZV3eMtvnbLC+acWvg=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies = with python3Packages; [
    rich
    textual
    pydantic
    click
    httpx
    python-dotenv
    pydantic-settings
    structlog
    keyring
    cryptography
    ty
    docker
  ];

  nativeBuildInputs = [
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd yt \
      --bash <($out/bin/yt completion bash) \
      --fish <($out/bin/yt completion fish) \
      --zsh <($out/bin/yt completion zsh)
  '';

  meta = {
    description = "Command line interface for JetBrains YouTrack issue tracking system";
    homepage = "https://github.com/ryancheley/yt-cli";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "yt";
  };
})
