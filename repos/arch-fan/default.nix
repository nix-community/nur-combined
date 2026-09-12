{
  pkgs,
}:

{
  crunchyroll = pkgs.callPackage ./pkgs/crunchyroll { };
  limusic = pkgs.callPackage ./pkgs/limusic { };
  rpcs3-bin = pkgs.callPackage ./pkgs/rpcs3-bin { };
}
