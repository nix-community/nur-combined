{ runCommand, unzip, callPackage }:

let
  robotnixZip = callPackage ./build-android.nix {};
in
runCommand "miodroid-robotnix-image" {
  nativeBuildInputs = [ unzip ];
} ''
  mkdir -p $out
  unzip ${robotnixZip} system.img vendor.img -d $out/
''
