{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeBinaryWrapper,
  nodejs,
}:
buildNpmPackage (finalAttrs: {
  pname = "ccmanager";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "kbwo";
    repo = "ccmanager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hGW2f+obSJbTz0KvIq/571dQoXw9BDuVlWIvnlQULkw=";
  };

  npmDepsHash = "sha256-8V6C0fF4txRfVhR6afTOu+JM/prfB2l30Qo6vhPrUJE=";

  nativeBuildInputs = [makeBinaryWrapper];

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/libexec/ccmanager $out/bin
    cp -r dist node_modules package.json $out/libexec/ccmanager/
    makeWrapper ${lib.getExe nodejs} $out/bin/ccmanager \
      --add-flags "$out/libexec/ccmanager/dist/cli.js"
    runHook postInstall
  '';

  meta = {
    description = "Coding Agent Session Manager for Claude Code, Gemini CLI and others";
    homepage = "https://github.com/kbwo/ccmanager";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "ccmanager";
  };
})
