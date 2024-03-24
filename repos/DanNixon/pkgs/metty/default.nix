{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage rec {
  pname = "metty";
  version = "2024.3.1";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "metty";
    rev = "v${version}";
    hash = "sha256-N7xhGXLXSHAdWIhH7+CRekJ5lEORRZcLQcWr6mO6Chs=";
  };

  nativeBuildInputs = [ installShellFiles ];

  cargoHash = "sha256-/XSjTJU43umtZxkavwVrXiWFoDM8nox8AvHg3X3zZwM=";

  # Nothing to test
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completions bash) \
      --fish <($out/bin/${pname} completions fish) \
      --zsh <($out/bin/${pname} completions zsh)
  '';

  meta = {
    description = "A CLI tool for getting real time information about the Tyne and Wear Metro.";
    homepage = "https://github.com/DanNixon/metty";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
