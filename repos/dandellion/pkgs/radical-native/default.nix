{
  pkgs, buildEnv, lib, fetchFromGitHub, rustPlatform,
  sqlcipher, ...
}:

let

  host = 
    rustPlatform.buildRustPackage rec {
      pname = "radical-native";
      version = "0.1.9";

      buildInputs = [ sqlcipher ];

      src = fetchFromGitHub {
        owner = "stoically";
        repo = pname;
        rev = "v0.1beta9";
        sha256 = "1saaczkpdb61wfdingjvvq25vmyvrlvry7xrdq877i9agzbrzknw";
      };

      cargoSha256 = "07499mybgr91kklbxcp3wlj0d2a3d25hj68w98z2xy1j1dkyhyw6";
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
