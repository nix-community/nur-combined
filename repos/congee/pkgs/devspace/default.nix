{ buildGoModule, fetchFromGitHub, lib, installShellFiles, ... }:

buildGoModule rec{
  pname = "devspace";
  version = "v5.18.4";
  vendorSha256 = null;

  src = fetchFromGitHub {
    owner = "loft-sh";
    repo = "devspace";
    rev = "refs/tags/${version}";
    sha256 = "sha256-IadUchjmBto+ISauAZRzMu8mRDNv51bidD2//tgJoWg=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    mkdir completion && $out/bin/gencompletion

    installShellCompletion \
      --bash completion/bash.sh \
      --zsh completion/zsh-completion \
      --fish completion/fish.fish

    find -L $out/bin -type f -not -name devspace -delete
  '';

  # nope
  doCheck = false;

  meta = with lib; {
    description = "The Fastest Developer Tool for Kubernetes. Automate your deployment workflow with DevSpace and develop software directly inside Kubernetes.";
    homepage = "https://devspace.sh/";
    licenses = licenses.asl20;
    # maintainers = with maintainers; [ congee ];  # not in <nixpkgs> yet
    mainProgram = "devspace";
  };
}
