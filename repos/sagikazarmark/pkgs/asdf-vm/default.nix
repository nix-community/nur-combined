{
  buildGoModule,
  lib,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
}:

buildGoModule rec {
  pname = "asdf-vm";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "asdf-vm";
    repo = "asdf";
    rev = "v${version}";
    sha256 = "sha256-BBd+MiRISjMz2m29nNIakG79Oy1k7bZI/Q24QQNp5CY=";
  };

  vendorHash = "sha256-gzlHXIzDYo4leP+37HgNrz5faIlrCLYA7AVSvZ6Uicc=";

  ldflags = [
    "-s"
    "-X main.version=v${version}"
  ];

  subPackages = [ "./cmd/asdf" ];

  doCheck = false;

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd asdf \
      --bash <($out/bin/asdf completion bash) \
      --fish <($out/bin/asdf completion fish) \
      --zsh <($out/bin/asdf completion zsh)
  '';

  meta = with lib; {
    description = "Extendable version manager with support for Ruby, Node.js, Erlang & more";
    homepage = "https://asdf-vm.com/";
    mainProgram = "asdf";
    platforms = platforms.unix;
  };
}
