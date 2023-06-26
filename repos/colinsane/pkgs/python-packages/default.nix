{ callPackage, pkgs }:
{
  feedsearch-crawler = callPackage ./feedsearch-crawler { };
  sane-lib = pkgs.sane-scripts.lib;
}
