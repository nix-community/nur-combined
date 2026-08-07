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
  version = "0.54.0";
  srcHash = "sha256-hQ29icpUC9bDHkxXc2GR5z9Q/jzW8vOyLghPJImBTMc=";
  npmDepsHash = "sha256-gWowNO8+B7KdkUUnSmaFLckX6WZe7GpvwZFz6CzkhTo=";

  src = runCommand "gemini-cli-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.54.0.tgz";
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
