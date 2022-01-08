{ pkgs, system, dataDir ? "/opt/zigbee2mqtt/data", nixosTests }:
let
  package = (import ./node.nix { inherit pkgs system; }).package;
in
package.override rec {
  version = "1.22.2";
  reconstructLock = true;

  src = pkgs.fetchFromGitHub {
    owner = "Koenkk";
    repo = "zigbee2mqtt";
    rev = version;
    sha256 = "sha256-HoheB+/K4THFqgcC79QZM71rDPv2JB+S6y4K1+sdASo=";
  };

  passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt;

  postInstall = ''
    node_modules/.bin/tsc
    node index.js writehash
  '';

  meta = with pkgs.lib; {
    description = "Zigbee to MQTT bridge using zigbee-shepherd";
    license = licenses.gpl3;
    homepage = https://github.com/Koenkk/zigbee2mqtt;
    maintainers = with maintainers; [ hexa ];
    platforms = platforms.linux;
  };
}
