{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  installShellFiles,
  pre-commit,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "jj-pre-push";
  version = "0.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "acarapetis";
    repo = "jj-pre-push";
    rev = "v${version}";
    hash = "sha256-dZrZjzygT6Q7jIPkasYgJ2uN3eyPQXsg0opksookLYI=";
  };

  build-system = [ python3.pkgs.uv-build ];

  dependencies = with python3.pkgs; [ typer-slim ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ pre-commit ])
  ];

  nativeBuildInputs = [ installShellFiles ];
  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd jj-pre-push \
      --bash <($out/bin/jj-pre-push --show-completion bash) \
      --fish <($out/bin/jj-pre-push --show-completion fish) \
      --zsh <($out/bin/jj-pre-push --show-completion zsh)
  '';

  pythonImportsCheck = [ "jj_pre_push" ];

  meta = {
    description = "Run pre-commit.com before jj git push";
    homepage = "https://github.com/acarapetis/jj-pre-push";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "jj-pre-push";
  };
}
