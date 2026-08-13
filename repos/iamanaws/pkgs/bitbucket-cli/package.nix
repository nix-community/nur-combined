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
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "avivsinai";
    repo = "bitbucket-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RxOG0IZnRBty4gVKCAtNxDRQH4K7qtYu+GA/b8eBk7I=";
  };

  vendorHash = "sha256-9wjEq4a5snJJ4uD4y+O3wJ15vVNs6Mcu8JVG43n94To=";

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
