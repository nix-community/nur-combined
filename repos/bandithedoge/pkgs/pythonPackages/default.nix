{
  pkgs,
  sources,
  callPackage',
  ...
}: {
  py-slvs = callPackage' ./py-slvs;
}
