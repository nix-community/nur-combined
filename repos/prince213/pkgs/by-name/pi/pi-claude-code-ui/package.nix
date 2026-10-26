{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-claude-code-ui";
  version = "1.0.99";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "FammasMaz";
    repo = "pi-cc-tools";
    rev = "0e0529ca918b919674d5129d3640d1b7e9601e23";
    hash = "sha256-3/Q4vVoj1V1x3/55jBEJ2fs2hg/A92iii2GIL0hqjzs=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-mGtjW1VGWSeWeKJHIodXMdvPLPreDxf/rnUDiIEE70I=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-claude-code-ui/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Claude Code-style grouped tool rows for the Pi coding agent";
    homepage = "https://github.com/FammasMaz/pi-cc-tools";
    changelog = "https://github.com/FammasMaz/pi-cc-tools/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
