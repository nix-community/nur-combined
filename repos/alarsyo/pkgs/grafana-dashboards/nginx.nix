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

  version = "0.9.0";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "grafana-dashboard-nginx";

    dontBuild = true;

    src = fetchFromGitHub {
      owner = "nginxinc";
      repo = "nginx-prometheus-exporter";
      rev = "v${version}";
      sha256 = "sha256:04y5vpj2kv2ygdzxy3crpnx4mhpkm1ns2995kxgvjlhnyck7a5rf";
    };

    installPhase = ''
      mkdir -p $out
      cp grafana/dashboard.json $out/dashboard.json
    '';

    meta = {
      description = "grafana dashboard for NGINX exporter";
      homepage = "https://github.com/nginxinc/nginx-prometheus-exporter";
      license = licenses.asl20;
    };
  }
