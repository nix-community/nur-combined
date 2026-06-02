{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "zydepoint-tailscale-dashboard";
  version = "0-unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "Zydepoint";
    repo = "Tailscale-dashboard";
    rev = "4e3b8347960828ecd3ad9cddcb3e9153255624d8";
    hash = "sha256-N+1pNTuBJrV0aV9ADtC4yqRaK8Iil25xW4BhDHfBlZ4=";
  };

  outputs = [
    "out"
    "prometheus"
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp dashboard-json.txt $out/tailscale.json

    cp dashboard-json.txt $prometheus

    runHook postInstall
  '';

  meta = {
    description = "Tailscale traffic with Grafana";
    homepage = "https://github.com/Zydepoint/Tailscale-dashboard";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
