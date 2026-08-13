{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  installShellFiles,
}:
buildGo126Module rec {
  pname = "settuings";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "settuings";
    rev = "v${version}";
    hash = "sha256-j5lY0pdQmKQmZ+PYioa9rYxPS8SUENar5rSWdbBLY9c=";
  };

  vendorHash = "sha256-EPbAZPJ0ZdfKqS7JNvjfRkdhRKD5F+epqBpOrPoT3S4=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd settuings \
      --bash <($out/bin/settuings completion bash) \
      --zsh <($out/bin/settuings completion zsh) \
      --fish <($out/bin/settuings completion fish)
  '';

  meta = with lib; {
    description = "A TUI to manage your Linux system settings like wifi, bluetooth, and more, without leaving the terminal.";
    homepage = "https://github.com/anotherhadi/settuings";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "settuings";
  };
}
