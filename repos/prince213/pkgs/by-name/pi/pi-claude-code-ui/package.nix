{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-claude-code-ui";
  version = "1.0.102";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "FammasMaz";
    repo = "pi-cc-tools";
    rev = "10b1675ac141d242a9b5ea82cff647e996fe5d73";
    hash = "sha256-vEQpbXCnFzBjdYsFLEo0CITmw+pFlbTrfi4t5MK8SuQ=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-ldOUyImK+oaNZbEqfFDfu3sLapsgkdB2zEeCMyfuNuI=";

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
