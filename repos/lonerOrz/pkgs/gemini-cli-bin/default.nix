{
  lib,
  ripgrep,
  fetchurl,
  buildNpmPackage,
  fetchNpmDeps,
  runCommand,
  ...
}:
let
  pname = "gemini-cli-bin";
  version = "0.50.0";
  srcHash = "sha256-sY2EIS3/nu8DUvnNmaAk9dl1d2ZoN3jhxAIYgnx0HdQ=";
  npmDepsHash = "sha256-gb3AeWEfX0KHGlJhz+co3gRF+/PJzFxPFM4ChqCy28k=";

  src = runCommand "gemini-cli-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.50.0.tgz";
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

  npmFlags = [ "--ignore-scripts" ];

  postInstall = ''
    mkdir -p $out/lib/node_modules/${pname}/node_modules/@lvce-editor/ripgrep/bin
    ln -s ${ripgrep}/bin/rg $out/lib/node_modules/${pname}/node_modules/@lvce-editor/ripgrep/bin/rg
  '';

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
