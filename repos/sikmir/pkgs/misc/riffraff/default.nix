{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  buildPackages,
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

#  postInstall =
#    let
#      riffraff =
#        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
#          placeholder "out"
#        else
#          buildPackages.riffraff;
#    in
#    ''
#      export JENKINS_URL="http://example.com/"
#      export JENKINS_USER="username"
#      export JENKINS_PW="password"
#      installShellCompletion --cmd riffraff \
#        --bash <(${riffraff}/bin/riffraff completion bash) \
#        --fish <(${riffraff}/bin/riffraff completion fish) \
#        --zsh <(${riffraff}/bin/riffraff completion zsh)
#    '';

  meta = {
    description = "A commandline interface for Jenkins";
    homepage = "https://github.com/mre/riffraff";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "riffraff";
  };
}
