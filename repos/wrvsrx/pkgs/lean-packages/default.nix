{
  sources,
}:
final: prev: {
  get-environment = final.callPackage ./get-environment { source = sources.get-environment; };
  xdg = final.callPackage ./xdg { source = sources.xdg; };
  xdg-user-dirs = final.callPackage ./xdg-user-dirs { source = sources.xdg-user-dirs; };
  xml = final.callPackage ./xml { source = sources.xml; };
}
