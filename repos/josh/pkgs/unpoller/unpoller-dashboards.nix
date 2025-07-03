{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "unpoller-dashboards";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "dashboards";
    rev = "e1b7c4958fd4e5dd70e0db050422c53d2bce4f0f";
    hash = "sha256-RsUxkVbWwM1hx/x3Z2VQTCbLBNPlX61SzLjJKw6fYiQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -R ./v2.0.0/*.json $out/

    runHook postInstall
  '';

  # passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "UniFi Poller Grafana Dashboards";
    homepage = "https://github.com/unpoller/dashboards";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
