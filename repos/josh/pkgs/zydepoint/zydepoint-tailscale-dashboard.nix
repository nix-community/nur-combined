{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zydepoint-tailscale-dashboard";
  version = "0-unstable-2025-02-09";

  outputs = [
    "out"
    "prometheus"
  ];

  src = fetchFromGitHub {
    owner = "Zydepoint";
    repo = "Tailscale-dashboard";
    rev = "4e3b8347960828ecd3ad9cddcb3e9153255624d8";
    hash = "sha256-N+1pNTuBJrV0aV9ADtC4yqRaK8Iil25xW4BhDHfBlZ4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp dashboard-json.txt $out/tailscale.json

    cp dashboard-json.txt $prometheus

    runHook postInstall
  '';

  passthru.tests = {
    json =
      runCommand "test-zydepoint-tailscale-dashboard-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          jq --exit-status . ${finalAttrs.finalPackage}/tailscale.json >/dev/null
          jq --exit-status . ${finalAttrs.finalPackage.prometheus} >/dev/null
          touch $out
        '';
  };

  meta = {
    description = "Tailscale traffic with Grafana";
    homepage = "https://github.com/Zydepoint/Tailscale-dashboard";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
