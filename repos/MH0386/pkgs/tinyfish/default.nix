{
  buildNpmPackage,
  fetchurl,
  lib,
  versionCheckHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "tinyfish";
  version = "0.1.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/@tiny-fish/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-vmZjZYKnJ8IadMl1Gq9Q84YXQcNhfVmLQp/lrr4SHQI=";
  };

  npmDepsHash = "sha256-cDQ6nv7WzpdYvv2DX601jGsWKDxvJ1YmiIwIDqvplPc=";

  postPatch = "cp ${./package-lock.json} package-lock.json";

  dontNpmBuild = true;

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "CLI for running TinyFish web automations from the terminal";
    homepage = "https://docs.tinyfish.ai/cli";
    mainProgram = "tinyfish";
    maintainers = [ lib.maintainers.MH0386 ];
  };
})
