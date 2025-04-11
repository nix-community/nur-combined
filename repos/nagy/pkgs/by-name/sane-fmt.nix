{
  lib,
  stdenv,
  installShellFiles,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "sane-fmt";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "sane-fmt";
    repo = "sane-fmt";
    rev = version;
    hash = "sha256-DJBphNc9fMdmnD9k12YLCpJI1IUjVyH94XBu2LChWJQ=";
  };

  cargoHash = "sha256-16/CxiZmPpHt5qSZmz9eWPgJnQf80iaV2mYb9F8rxZE=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sane-fmt \
      --bash <($out/bin/sane-fmt-generate-shell-completions --shell bash --name sane-fmt --output /dev/stdout) \
      --fish <($out/bin/sane-fmt-generate-shell-completions --shell fish --name sane-fmt --output /dev/stdout) \
      --zsh <($out/bin/sane-fmt-generate-shell-completions --shell zsh --name sane-fmt --output /dev/stdout)
  '';

  meta = {
    description = "Opinionated code formatter for TypeScript and JavaScript";
    homepage = "https://github.com/sane-fmt/sane-fmt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "sane-fmt";
  };
}
