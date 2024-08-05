{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage {
  pname = "emfcamp-schedule-cli";
  version = "2024-04-28";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "emfcamp-schedule-api";
    rev = "b6c3b7005cded9369a51602e20bc3b6d9f86f44a";
    hash = "sha256-PnMLckK75BI/cE94xCK1bJYrovReXd9/UZHyxl/AFuI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  cargoHash = "sha256-QycpIushzoZKHc9PvLoqYfnr3WWAvt+jC7Q02ffjlS8=";

  buildAndTestSubdir = "cli";

  doCheck = false;

  # FIXME: not sure quite why this is causing build failures
  # postInstall = ''
  #   installShellCompletion --cmd ${pname} \
  #     --bash <($out/bin/${pname} shell-completions bash) \
  #     --fish <($out/bin/${pname} shell-completions fish) \
  #     --zsh <($out/bin/${pname} shell-completions zsh)
  # '';

  meta = {
    description = "A CLI client for the EMF camp schedule API.";
    homepage = "https://github.com/DanNixon/emfcamp-schedule-cli";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
