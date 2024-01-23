{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "ioxy";
  version = "2023-08-20";

  src = fetchFromGitHub {
    owner = "NVISOsecurity";
    repo = "IOXY";
    rev = "6f1d0ffc02cde306caa837713f9a9f81352f13cf";
    hash = "sha256-j3qKlR0dwu0ZHc38JMGUjwVpN2s16ZIiRU8W+lI/X0s=";
  };

  sourceRoot = "${src.name}/ioxy";

  vendorHash = "sha256-VWw9yuwNnJYvIvl6ov24An867koyzPPbqNg0VIXCJiM=";

  meta = with lib; {
    description = "MQTT intercepting proxy";
    inherit (src.meta) homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
  };
}
