{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "bitbucket-cli";
  version = "0.30.1";

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "bitbucket-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yYVwybeVfvBJtKtdMeiWMopRuMZuXu66Z2FwTR8PBs4=";
  };

  vendorHash = "sha256-uEziVUGmnsUKcAQReNWDDaI+IfhyF5TavYqZbC18n4Q=";

  subPackages = [ "cmd/bkt" ];

  preCheck = ''
    # Test all packages, not only cmd/bkt.
    unset subPackages
  '';

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-X github.com/avivsinai/bitbucket-cli/internal/build.versionFromLdflags=${finalAttrs.version}"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for sh in bash fish zsh; do
      installShellCompletion --cmd bkt --$sh <($out/bin/bkt completion $sh)
    done
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Bitbucket CLI for Cloud and Data Center";
    homepage = "https://github.com/avivsinai/bitbucket-cli";
    changelog = "https://github.com/avivsinai/bitbucket-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "bkt";
  };
})
