{ keystone, callPackage }:
let
  keystone-native = keystone;
in
rec {
  chump = callPackage ./chump.nix { };

  jupyterthemes = callPackage ./jupyterthemes.nix {
    inherit lesscpy;
  };

  gatt = callPackage ./gatt.nix { };

  keystone = callPackage ./keystone.nix {
    keystone = keystone-native;
  };

  ldap0 = callPackage ./ldap0.nix { };

  lesscpy = callPackage ./lesscpy.nix { };

  pry = callPackage ./pry.nix { };

  priority = callPackage ./priority.nix { };

  pyps4-2ndscreen = callPackage ./pyps4-2ndscreen.nix { };

  remote-pdb = callPackage ./remote-pdb.nix { };

  web2ldap = callPackage ./web2ldap {
    inherit ldap0;
  };
}
