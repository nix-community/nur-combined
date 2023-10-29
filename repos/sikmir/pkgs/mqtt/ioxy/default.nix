{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "ioxy";
  version = "2022-11-25";

  src = fetchFromGitHub {
    owner = "NVISOsecurity";
    repo = "IOXY";
    rev = "023e9e64cc3e9fe6a330c640fc56f7abb985c64e";
    hash = "sha256-bhJgWnscT+qEVZHXQb9l72pm0q4NTBFnWmTqnhA6PSM=";
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
