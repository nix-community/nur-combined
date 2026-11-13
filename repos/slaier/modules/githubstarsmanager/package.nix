{
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs_22,
  python3,
}:

let
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "AmintaCCCP";
    repo = "GithubStarsManager";
    rev = "v${version}";
    hash = "sha256-spQrJLZ9IZuMOuD0yZFfH+Y/YxbMqz6CqoSQUoHdA/4=";
  };

  frontend = buildNpmPackage {
    pname = "githubstarsmanager-frontend";
    inherit version src;
    nodejs = nodejs_22;
    npmDeps = fetchNpmDeps {
      inherit version src;
      hash = "sha256-/5BsvCbbMiKxqf8Mu1z6gPVm7lbKY+7QZts/QvOjH6U=";
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
    npmDepsHash = "sha256-NklWtQcNULO6aviTp5LEzkOjPaiw5kLgoLsky8f/Pj0=";
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
      # the prebuilt vite/rolldown client imports its own chunks as data: URLs, which
      # helmet's default script-src 'self' blocks, leaving a blank page
      sed -i 's|\x27connect-src\x27: buildConnectSrc()|"script-src": ["\x27self\x27", "data:"],\n                \x27connect-src\x27: buildConnectSrc()|' $out/dist/index.js
      runHook postInstall
    '';
    passthru = {
      inherit frontend;
    };
  };
in
server
