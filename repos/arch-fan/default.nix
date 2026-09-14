{
  pkgs,
}:

{
  chat-on-steroids = pkgs.callPackage ./pkgs/chat-on-steroids { };
  crunchyroll = pkgs.callPackage ./pkgs/crunchyroll { };
  limusic = pkgs.callPackage ./pkgs/limusic { };
  rpcs3-bin = pkgs.callPackage ./pkgs/rpcs3-bin { };
}
