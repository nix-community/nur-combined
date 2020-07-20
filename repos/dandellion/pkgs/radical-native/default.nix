{
  pkgs, buildEnv, lib, fetchFromGitHub, rustPlatform,
  sqlcipher, ...
}:

let
  host = 
    rustPlatform.buildRustPackage rec {
      pname = "radical-native";
      version = "0.1.10";

      buildInputs = [ sqlcipher ];

      src = fetchFromGitHub {
        owner = "stoically";
        repo = pname;
        rev = "v0.1beta10";
        sha256 = "1gd1k9my7qp2gp8k149ga2dcw14yxxb0ld6j3856wz5a2yr4izi2";
      };

      cargoSha256 = "1ll320ljikrv1v8a7k07smp4syc969fwpxfc2b7axn6pc6l8izi8";
    };

  manifest = pkgs.writeTextFile {
    name = "radical.native.json";
    destination = "/lib/mozilla/native-messaging-hosts/radical.native.json";
    text = ''
      {
        "name": "radical.native",
        "description": "Radical Native",
        "path": "${host}/bin/radical-native",
        "type": "stdio",
        "allowed_extensions": [ "@radical-native" ]
      }
    '';
  };
in
buildEnv {
  name = "radical-nativeFull";
  paths = [ host manifest ];
}
