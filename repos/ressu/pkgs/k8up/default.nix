{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "k8up";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "k8up-io";
    repo = "k8up";
    rev = "v${version}";
    hash = "sha256-cmWeun8BYgOLFFFDOwrx7g/oU37RJNF969mW4XKuXOQ=";
  };

  vendorHash = "sha256-C6Rt1Urf5iLyArqVc8gVT7jPYHUkpf53xqSNZB3yX7M=";

  subPackages = [ "cmd/k8up" ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  postInstall = ''
    cat <<'EOF' > k8up.bash
_k8up_complete() {
    local cur
    COMPREPLY=()
    cur="''${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "K8UP_EXE --generate-bash-completion" -- "''${cur}") )
    return 0
}
complete -F _k8up_complete k8up
EOF
    sed -i "s|K8UP_EXE|$out/bin/k8up|" k8up.bash
    installShellCompletion --bash k8up.bash
  '';

  meta = with lib; {
    description = "Kubernetes backup operator based on Restic";
    homepage = "https://k8up.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "k8up";
  };
}
