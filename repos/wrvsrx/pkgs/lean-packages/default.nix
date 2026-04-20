{
  sources,
}:
final: prev: {
  get-environment = final.callPackage ./get-environment { source = sources.get-environment; };
  xdg = final.callPackage ./xdg { source = sources.xdg; };
}
