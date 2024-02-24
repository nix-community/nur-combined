{ lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  pname = "janus-mqtt-proxy";
  version = "0-unstable-2022-02-19";

  src = fetchFromGitHub {
    owner = "phoenix-mstu";
    repo = "janus-mqtt-proxy";
    rev = "bfdebffb6e277db00adf14d9a11f792cf418358a";
    hash = "sha256-RjhIV5GDHqtGz54Zfaph5JleBaAIDwIWGiknl1KNW+8=";
  };

  subPackages = [ "cmd/proxy" ];
  goPackagePath = "github.com/phoenix-mstu/janus-mqtt-proxy";

  goDeps = ./deps.nix;

  postInstall = ''
    install -Dm644 $src/sample_configs/*.yaml -t $out/share/janus-mqtt-proxy/sample_configs
  '';

  meta = with lib; {
    description = "MITM proxy which can filter and modify MQTT packets";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
