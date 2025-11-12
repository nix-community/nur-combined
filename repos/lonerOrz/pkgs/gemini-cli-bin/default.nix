{
  lib,
  ripgrep,
  nodejs_20,
  fetchurl,
  buildNpmPackage,
  fetchNpmDeps,
  runCommand,
  ...
}:
let
  pname = "gemini-cli";
  version = "0.14.0";
  srcHash = "sha256-NmAn0sb9Wvryp6wIoAt7c/4+7e8QIQwVdolsTN6Nrc0=";
  npmDepsHash = "sha256-1Y59zw0KwmShBcfjq2LaxaUZU5YDIKPgR0doB7AXbgs=";

  src = runCommand "gemini-cli-src-with-lock" { } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.14.0.tgz";
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

  nodejs = nodejs_20;

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
