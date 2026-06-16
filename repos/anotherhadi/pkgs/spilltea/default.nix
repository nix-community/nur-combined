{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  installShellFiles,
}:
buildGo126Module rec {
  pname = "spilltea";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "spilltea";
    rev = "v${version}";
    hash = "sha256-xOJ+VvrdPRyNJBVo+1Sd1tvw++OWbBN59uWI3Tc/hCY=";
  };

  vendorHash = "sha256-Mz5TLKcQKk9cuPNOpMl6hgaODKlaw137B00e3M6fgwM=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd spilltea \
      --bash <($out/bin/spilltea completion bash) \
      --zsh <($out/bin/spilltea completion zsh) \
      --fish <($out/bin/spilltea completion fish)
  '';

  meta = with lib; {
    description = "A minimal, terminal-based HTTP(S) proxy for pentesters and CTF players.";
    homepage = "https://github.com/anotherhadi/spilltea";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "spilltea";
  };
}
