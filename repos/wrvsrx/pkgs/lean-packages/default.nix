final: prev: {
  lean-posix = final.callPackage ./lean-posix { };
  xdg = final.callPackage ./xdg { };
  xdg-user-dirs = final.callPackage ./xdg-user-dirs { };
  xml = final.callPackage ./xml { };
}
