{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage {
  pname = "emfcamp-schedule-cli";
  version = "2024-08-17";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "emfcamp-schedule-api";
    rev = "edcabdbbbbf9469a02b7a915365d2f8e1a8d21a7";
    hash = "sha256-l1xftUVQdSbcy1iEuyYp8n/16RqkgZ3HGJ4QIoHYEYU=";
  };

  nativeBuildInputs = [ installShellFiles ];

  cargoHash = "sha256-rYUMxeSkOctRVV6RpgeMnP78z5sXlRi5SrKrVCoCBlo=";

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
