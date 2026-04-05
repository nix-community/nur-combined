{
  sources,
}:
final: prev: {
  xdg = final.callPackage ./xdg { source = sources.xdg; };
}
