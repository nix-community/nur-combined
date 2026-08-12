{
  lib,
  buildGo126Module,
  fetchFromGitHub,
  installShellFiles,
}:
buildGo126Module rec {
  pname = "settuings";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "settuings";
    rev = "v${version}";
    hash = "sha256-dbm12xD6LkUxT3aePPWQs7BVkRInGMYfEuK5DHS5Qvk=";
  };

  vendorHash = "sha256-CWWDjtrCUZf2kHUin7n+U54artAFlp36xlc7C0xHXXI=";

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
