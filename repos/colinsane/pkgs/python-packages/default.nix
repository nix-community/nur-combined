{ callPackage, pkgs }:
{
  feedsearch-crawler = callPackage ./feedsearch-crawler { };
  pa-dlna = callPackage ./pa-dlna { };
  pyln-bolt7 = callPackage ./pyln-bolt7 { };
  pyln-client = callPackage ./pyln-client { };
  pyln-proto = callPackage ./pyln-proto { };
  sane-lib = pkgs.sane-scripts.lib;
}
