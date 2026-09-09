{ fetchFromGitHub
, gitUpdater
, lib
, stdenvNoCC
}:

let
  inherit (lib) licenses;
in
stdenvNoCC.mkDerivation (ai-robots-txt: {
  pname = "ai-robots-txt";
  version = "1.52";
  meta = {
    description = "List of AI agents and robots to block";
    homepage = "https://github.com/ai-robots-txt/ai.robots.txt";
    license = licenses.mit;
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromGitHub {
    owner = "ai-robots-txt";
    repo = "ai.robots.txt";
    rev = "refs/tags/v${ai-robots-txt.version}";
    hash = "sha256-jgLm8qvmAIkVAZBGgUNUJrwX+Z4Y/OLTD/mlS71Ha2g=";
  };

  installPhase = ''
    runHook preInstall

    mkdir --parents "$out/share/ai-robots-txt"
    cp --target-directory "$out/share/ai-robots-txt" \
      '.htaccess' \
      'Caddyfile' \
      'haproxy-block-ai-bots.txt' \
      'nginx-block-ai-bots.conf' \
      'robots.json' \
      'robots.txt'

    runHook postInstall
  '';
})
