{ callPackage }:
rec {
  chump = callPackage ./chump.nix { };

  jupyterthemes = callPackage ./jupyterthemes.nix {
    inherit lesscpy;
  };

  gatt = callPackage ./gatt.nix { };

  ldap0 = callPackage ./ldap0.nix { };

  lesscpy = callPackage ./lesscpy.nix { };

  pry = callPackage ./pry.nix { };

  priority = callPackage ./priority.nix { };

  remote-pdb = callPackage ./remote-pdb.nix { };

  web2ldap = callPackage ./web2ldap {
    inherit ldap0;
  };
}
