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
  version = "0.40.1";

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "bitbucket-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DUuJXw1S5Dc0l4YZxyhauKzJCSN7i/Edtc8jIK+Vkdg=";
  };

  vendorHash = "sha256-lZ1/EFTS9dVH844Z3q7qEdWFo673nTGmDA84WCT777M=";

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
