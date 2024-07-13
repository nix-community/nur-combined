{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "mochi";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "mochi-mqtt";
    repo = "server";
    rev = "v${version}";
    hash = "sha256-oQDxagj4+am6DNfdZB1iHwlfFW0Q/b4Sq8YiP5sVqWM=";
  };

  vendorHash = "sha256-+28spfekUVTDCvDgmKXpHNRQNAlQ4k9lEU4H6gZu9ZI=";

  postInstall = ''
    mv $out/bin/{cmd,mochi}
    mv $out/bin/{docker,mochi-docker}
  '';

  meta = {
    description = "The fully compliant, embeddable high-performance Go MQTT v5 server for IoT, smarthome, and pubsub";
    homepage = "https://github.com/mochi-mqtt/server";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
