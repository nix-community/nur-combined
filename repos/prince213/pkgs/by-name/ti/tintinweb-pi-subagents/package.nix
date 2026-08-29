{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "tintinweb-pi-subagents";
  version = "0.19.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1K6U5+2qLgOV7lUWbvqUne/Pf7oMRDf40GXLl8gv6Bk=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-xy4e+c6sEuX9vmIlBcU6xUPlUex6pd0/NnZzEPhdorY=";

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
