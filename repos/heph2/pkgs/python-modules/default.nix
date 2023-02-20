{ keystone, callPackage }:
let
  keystone-native = keystone;
in
rec {
  keystone = callPackage ./keystone.nix {
    keystone = keystone-native;
  };

  roundrobin = callPackage ./roundrobin { };
  locustio = callPackage ./locustio {
    inherit roundrobin;
  };
}
