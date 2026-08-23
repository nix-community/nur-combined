{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "tintinweb-pi-subagents";
  version = "0.18.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tintinweb";
    repo = "pi-subagents";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gpaIK622/IMHIEQDIvg7IhazDkvl5HVU8dU16jkP2jk=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-yBHUMQf6rgeRGEGbkI8ekp96Ddxwcp8s1VkicbF9TEA=";

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
