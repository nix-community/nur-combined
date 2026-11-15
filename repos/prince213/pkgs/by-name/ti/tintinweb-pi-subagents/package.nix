{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "tintinweb-pi-subagents";
  version = "0.25.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0cb/ChDsFettIuwWIrHNa7tOSpUEULgr2jITW/kqlpo=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-2jKoo2Vz9aOeXc8brAe5o5Ex4gnSqwpUclme+9Fcf8E=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    rm -rf $out/bin
    cp -r $out/lib/node_modules/@tintinweb/pi-subagents/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extension that brings Claude Code-style autonomous subagents to Pi";
    homepage = "https://github.com/tintinweb/pi-subagents";
    downloadPage = "https://github.com/tintinweb/pi-subagents/releases";
    changelog = "https://github.com/tintinweb/pi-subagents/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
