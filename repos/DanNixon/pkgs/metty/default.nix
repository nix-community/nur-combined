{
  lib,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
}:
rustPlatform.buildRustPackage rec {
  pname = "metty";
  version = "2024.7.0";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "metty";
    rev = "v${version}";
    hash = "sha256-u4EhLuZIDzAMfesN1BLO5OzXphRVICKK5UxHYZFiGcI=";
  };

  nativeBuildInputs = [ installShellFiles ];

  cargoHash = "sha256-4xGeXYZfNPPVUHVg7rcTR29IpJzPKKfCEALmUwUD8zw=";

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
