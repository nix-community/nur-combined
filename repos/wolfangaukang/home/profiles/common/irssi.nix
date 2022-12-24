{ ... }:

{
  programs.irssi = {
    enable = true;
    aliases = {
      "XAU" = "quit";
      "J" = "join";
    };
    networks = {
      freenode = {
        nick = "wolfangaukang";
        server = {
          address = "chat.freenode.net";
          port = 6697;
          autoConnect = true;
        };
        channels = {
          nixos.autoJoin = true;
        };
      };
    };
  };
}
