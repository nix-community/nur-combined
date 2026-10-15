{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs_22,
  python3,
  runCommand,
}:

let
  version = "0.8.6";
  src = fetchFromGitHub {
    owner = "AmintaCCCP";
    repo = "GithubStarsManager";
    rev = "v${version}";
    hash = "sha256-5RPXwpPXm3Twil9PABGVXPW8f3ugwHsz+CKZCky2thw=";
  };

  # upstream lockfile requests babel-plugin-polyfill-corejs3@^0.13.0 but only
  # pins 0.14.2, which `npm ci` rejects; align the spec with the pinned version
  srcPatched = runCommand "githubstarsmanager-src-patched" { } ''
    cp -r ${src} $out
    chmod -R u+w $out
    sed -i 's|"babel-plugin-polyfill-corejs3": "^0.13.0"|"babel-plugin-polyfill-corejs3": "^0.14.2"|' $out/package-lock.json
  '';

  frontend = buildNpmPackage {
    pname = "githubstarsmanager-frontend";
    inherit version;
    src = srcPatched;
    nodejs = nodejs_22;
    npmDeps = fetchNpmDeps {
      inherit version;
      src = srcPatched;
      hash = "sha256-nQ162HSjS1qMEgLbwzQu476J5/Kzr1bYG3DFeRNEEOQ=";
    };
    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };

  server = buildNpmPackage {
    pname = "githubstarsmanager-server";
    inherit version src;
    nodejs = nodejs_22;
    sourceRoot = "source/server";
    npmDepsHash = "sha256-V50fDXA+X3ytFy35dWNt9r742owHo1LfGOTupUtNa2I=";
    nativeBuildInputs = [ python3 ];
    postBuild = "npm prune --omit=dev";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/dist
      cp -r node_modules $out/node_modules
      cp package.json $out/package.json
      cp -r ${frontend} $out/public
      # local-only deployment: let /api/proxy reach loopback/private targets
      # (e.g. local llama.cpp); upstream only allows them with a saved outbound proxy config
      sed -i 's|const allowPrivate = Boolean(configId);|const allowPrivate = true;|' $out/dist/routes/proxy.js
      runHook postInstall
    '';
  };
in
server
