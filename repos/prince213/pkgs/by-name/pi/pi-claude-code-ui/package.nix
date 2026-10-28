{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-claude-code-ui";
  version = "1.0.106";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "FammasMaz";
    repo = "pi-cc-tools";
    rev = "f9d2074f9d619777d968f321a29b5037ef062c53";
    hash = "sha256-Kd9NlO4yEC/kywJ7ojTYieeYCtra8Y5jsLPWvqLXXCM=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-U2HeozfzVAcCSWneAIXHx9eiVGIvQbFSa9fEC/iM0oA=";

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
