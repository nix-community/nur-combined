{
  fetchFromGitHub,
  lib,
  buildGoModule,
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

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  postInstall = ''
    mv $out/bin/cmd $out/bin/kuake-cli
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/zhangjingwei/kuake_cli/releases/tag/v${finalAttrs.version}";
    description = "CLI tool for Quark cloud storage management";
    homepage = "https://github.com/zhangjingwei/kuake_cli";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "kuake-cli";
  };
})
