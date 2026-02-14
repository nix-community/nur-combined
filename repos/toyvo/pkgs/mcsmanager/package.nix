{ callPackage, lib, ... }:
lib.recurseIntoAttrs {
  mcsmanager-daemon = callPackage ./daemon.nix { };
  mcsmanager-web = callPackage ./web.nix { };
}
