{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule {
  pname = "riffraff";
  version = "0.5.0-unstable-2022-10-25";

  src = fetchFromGitHub {
    owner = "mre";
    repo = "riffraff";
    rev = "d4aa7ff38660cc2c5df30954789ee5d45d78836d";
    hash = "sha256-gWzbU2PX5AD0lKBQ/HKPHPmDDQByVv/IR4Xq0oTQJ2A=";
  };

  vendorHash = null;

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd riffraff \
      --bash <($out/bin/riffraff completion bash) \
      --fish <($out/bin/riffraff completion fish) \
      --zsh <($out/bin/riffraff completion zsh)
  '';

  meta = {
    description = "A commandline interface for Jenkins";
    homepage = "https://github.com/mre/riffraff";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "riffraff";
  };
}
