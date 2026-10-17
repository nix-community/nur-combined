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
  version = "2.1";
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
    hash = "sha256-ZKYoXYkOf4qLwL8qSZx1HL/mEfBYTPU91hNWYkDzyu0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir --parents "$out/share/ai-robots-txt"
    cp --target-directory "$out/share/ai-robots-txt" \
      '.htaccess' \
      'Caddyfile' \
      'haproxy-block-ai-bots.txt' \
      'lighttpd-block-ai-bots.conf' \
      'nginx-block-ai-bots.conf' \
      'robots.json' \
      'robots.txt'

    runHook postInstall
  '';
})
