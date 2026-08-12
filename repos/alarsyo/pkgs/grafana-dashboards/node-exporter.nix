{
  stdenv,
  fetchFromGitHub,
  lib,
  ...
}: let
  inherit
    (lib)
    licenses
    ;

  version = "7d61c79619e5749e629758ecd96748c010028120";
in
  stdenv.mkDerivation {
    version = "master-${version}";
    pname = "grafana-dashboard-node-exporter";

    dontBuild = true;

    src = fetchFromGitHub {
      owner = "rfrail3";
      repo = "grafana-dashboards";
      rev = version;
      sha256 = "sha256:1z6i76jdiw3jjigbmbqvyi8kyj4ngw0y73fv9yksr2ncjfqlhhv6";
    };

    installPhase = ''
      mkdir -p $out
      cp prometheus/node-exporter-full.json $out/node-exporter-full.json
    '';

    meta = {
      description = "grafana dashboard for node exporter";
      homepage = "https://github.com/rfrail3/grafana-dashboards";
      license = licenses.lgpl3Only;
    };
  }
