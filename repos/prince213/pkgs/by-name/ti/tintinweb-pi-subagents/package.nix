{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchpatch2,
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

  patches = [
    # https://github.com/tintinweb/pi-subagents/pull/359
    (fetchpatch2 {
      url = "https://github.com/Arteiimis/pi-subagents/commit/dd12bee7726bc82bd7de87f31ea21042efddce8b.patch?full_index=1";
      hash = "sha256-714HuUY12HXf29+pjPYMxtkLKKbhL2lICLohhs71jlA=";
    })

    ./package-lock.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-dQrup+Iu7MJ/JVgovBTE7V4Pjx96SWtMbIyLsH/FkkQ=";

  npmInstallFlags = [ "--omit=dev" ];
  npmPruneFlags = [ "--legacy-peer-deps" ];

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
