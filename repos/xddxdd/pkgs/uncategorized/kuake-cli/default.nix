{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kuake-cli";
  version = "1.6.0";
  src = fetchFromGitHub {
    owner = "zhangjingwei";
    repo = "kuake_cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T9GHSkbin/9F1ROxReH7oIL+TvIXy7seRa3yBeogNJU=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-TLC+Vlyg/aplz+woGQ3fvnGZyModYsok/knl+xC92Ds=";

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
