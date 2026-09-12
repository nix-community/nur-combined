{
  pkgs,
}:

{
  crunchyroll = pkgs.callPackage ./pkgs/crunchyroll { };
  limusic = pkgs.callPackage ./pkgs/limusic { };
}
