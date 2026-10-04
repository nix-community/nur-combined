{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kuake-cli";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "zhangjingwei";
    repo = "kuake_cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-89XMY1UggK5X9rGdLRmC5brF/xrfmBI+vhJNy+oiRk0=";
  };

  vendorHash = "sha256-v/yHclHWgPWKNFEINmXc49aqYu1KBlKswdK61n3U2P8=";

  subPackages = [ "cmd" ];
  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  postInstall = ''
    mv "$out/bin/cmd" "$out/bin/kuake"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quark Cloud Drive file management CLI";
    homepage = "https://github.com/zhangjingwei/kuake_cli";
    changelog = "https://github.com/zhangjingwei/kuake_cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "kuake";
    platforms = lib.platforms.unix;
  };
})
