{
  lib,
  nodejs_20,
  fetchurl,
  buildNpmPackage,
  fetchNpmDeps,
  runCommand,
  ...
}:
let
  pname = "gemini-cli";
  version = "0.1.19";
  srcHash = "sha256-vgFJvwgI0P8/bIJovaDk8IOqtT+MjWLQb4nPFXmcJTI=";
  npmDepsHash = "sha256-qJnk/Zf5xGJOOo2woIqMnik2Da9NuJBvou9HOXDdJYA=";

  src = runCommand "gemini-cli-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.1.19.tgz";
        hash = "${srcHash}";
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage (finallAttrs: {
  inherit pname version src;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "${npmDepsHash}";
  };

  # The package from npm is already built
  dontNpmBuild = true;

  nodejs = nodejs_20;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    mainProgram = "gemini";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    binaryNativeCode = true;
  };
})
