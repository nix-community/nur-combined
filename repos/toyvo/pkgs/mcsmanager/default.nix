{ callPackage, lib, ... }:
lib.recurseIntoAttrs {
  mcsmanager-daemon = callPackage ./daemon.nix { inherit lib; };
  mcsmanager-web = callPackage ./web.nix { inherit lib; };
}
