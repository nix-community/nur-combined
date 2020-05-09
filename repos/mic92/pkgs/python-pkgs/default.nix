{ keystone, callPackage }:
let
  keystone-native = keystone;
in
rec {
  blurhash = callPackage ./blurhash.nix { };

  jupyterthemes = callPackage ./jupyterthemes.nix {
    inherit lesscpy;
  };

  frida = callPackage ./frida.nix { };

  gatt = callPackage ./gatt.nix { };

  http_ece = callPackage ./http_ece.nix { };

  keystone = callPackage ./keystone.nix {
    keystone = keystone-native;
  };

  ldap0 = callPackage ./ldap0.nix { };

  lesscpy = callPackage ./lesscpy.nix { };

  Mastodon = callPackage ./Mastodon.nix {
    inherit http_ece blurhash;
  };

  pry = callPackage ./pry.nix { };

  priority = callPackage ./priority.nix { };

  remote-pdb = callPackage ./remote-pdb.nix { };

  web2ldap = callPackage ./web2ldap {
    inherit ldap0;
  };
}
