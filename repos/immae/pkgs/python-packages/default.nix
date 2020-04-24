{ mylibs, callPackage, python }:
{
  apprise = callPackage ./apprise { inherit mylibs; pythonPackages = python.pkgs; };
  buildbot-plugins = callPackage ./buildbot/plugins { inherit mylibs python; };
  wokkel = callPackage ./wokkel.nix { pythonPackages = python.pkgs; };
  pymilter = callPackage ./pymilter.nix { pythonPackages = python.pkgs; };
}
