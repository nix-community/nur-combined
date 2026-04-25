{
  lib,
  buildGoModule,
  sources,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  inherit (sources.kuake-cli) pname version src;

  vendorHash = "sha256-NHTKwUSIbNCUco88JbHOo3gt6S37ggee+LWNbHaRGEs=";

  doCheck = false;

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  postInstall = ''
    mv $out/bin/cmd $out/bin/kuake-cli
  '';

  meta = {
    changelog = "https://github.com/zhangjingwei/kuake_cli/releases/tag/v${finalAttrs.version}";
    description = "CLI tool for Quark cloud storage management";
    homepage = "https://github.com/zhangjingwei/kuake_cli";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "kuake-cli";
  };
})
