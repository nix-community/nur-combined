{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "janus-mqtt-proxy";
  version = "0-unstable-2022-02-19";

  src = fetchFromGitHub {
    owner = "phoenix-mstu";
    repo = "janus-mqtt-proxy";
    rev = "bfdebffb6e277db00adf14d9a11f792cf418358a";
    hash = "sha256-RjhIV5GDHqtGz54Zfaph5JleBaAIDwIWGiknl1KNW+8=";
  };

  patches = [ ./go.mod.patch ];

  vendorHash = "sha256-dfllNAieT3scfsojOJoBSDpKJVkh9YwwRD9KvLwT2Jo=";

  subPackages = [ "cmd/proxy" ];

  postInstall = ''
    mv $out/bin/{proxy,janus-mqtt-proxy}
    install -Dm644 $src/sample_configs/*.yaml -t $out/share/janus-mqtt-proxy/sample_configs
  '';

  meta = {
    description = "MITM proxy which can filter and modify MQTT packets";
    homepage = "https://github.com/phoenix-mstu/janus-mqtt-proxy";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
