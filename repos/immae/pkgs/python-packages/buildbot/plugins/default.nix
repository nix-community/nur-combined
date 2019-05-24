{ mylibs, callPackage, python }:
{
  buildslist = callPackage ./buildslist {
    inherit mylibs;
    pythonPackages = python.pkgs;
  };
}
