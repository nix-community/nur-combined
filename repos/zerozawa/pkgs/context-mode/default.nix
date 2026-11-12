{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeBinaryWrapper,
  nodejs,
}:
# Upstream commits no lockfile: its release CI runs a bare `npm install` for the
# dev dependencies and then `node build/build.mjs` (esbuild bundles every src/
# import, so the whole devDependency tree is needed at build time). `package-lock.json`
# here is generated once from the tag with `npm install --package-lock-only`
# and must be regenerated when `version` moves, so `npm ci` stays reproducible.
buildNpmPackage rec {
  pname = "context-mode";
  version = "2.1.8";

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    rev = "v${version}";
    hash = "sha256-i+HJloc7N8rChAW0tn/FcYt2r5G3XMIdC2tjleTZCDM=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-dLP3gUlSgZ/1PpdRaVYwQdIarioxkAJcpeF5099iXTY=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild
    node build/build.mjs --out release-out --version ${version}
    runHook postBuild
  '';

  # Bundles are self-contained (no runtime node_modules): install the release
  # layout under lib/node_modules so createRequire(import.meta.url) resolves
  # relative to the CLI, and wrap cli.mjs for the interpreter.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/${pname}
    cp -r release-out/. $out/lib/node_modules/${pname}/

    makeBinaryWrapper ${lib.getExe nodejs} $out/bin/${pname} \
      --add-flags "$out/lib/node_modules/${pname}/cli.mjs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Free, local plugin that keeps tool output out of your coding agent's context window.";
    homepage = "https://github.com/mksglu/context-mode";
    license = licenses.elastic20;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = pname;
  };
}
