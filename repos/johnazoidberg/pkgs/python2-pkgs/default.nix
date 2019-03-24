{ callPackage }:
rec {
  tavern = callPackage ./tavern.nix { inherit pykwalify python-box paho-mqtt; };
  pykwalify = callPackage ./pykwalify.nix {};
  python-box = callPackage ./python-box.nix {};
  paho-mqtt = callPackage ./paho-mqtt.nix {};
}
