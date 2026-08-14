{
  sources,
}:
final: prev: {
  lean-posix = final.callPackage ./lean-posix { source = sources.lean-posix; };
  xdg = final.callPackage ./xdg { source = sources.xdg; };
  xdg-user-dirs = final.callPackage ./xdg-user-dirs { source = sources.xdg-user-dirs; };
  xml = final.callPackage ./xml { source = sources.xml; };
}
