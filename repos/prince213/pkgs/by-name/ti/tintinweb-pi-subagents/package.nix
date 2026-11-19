{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "tintinweb-pi-subagents";
  version = "0.26.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dNqxqJiimPxJ8IazMYWmq5AaOX/7kYHbM3KPl1zYPAg=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-kXffWi1EyNNfou5c6gwH39BTdmOVLZLIW4ZHKrZkySw=";

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
