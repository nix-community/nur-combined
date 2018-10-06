{ callPackage }:

rec {
  aioh2 = callPackage ./aioh2.nix {
    inherit priority;
  };

  aiohttp-remotes = callPackage ./aiohttp-remotes.nix {};

  jupyterthemes = callPackage ./jupyterthemes.nix {
    inherit lesscpy;
  };

  frida = callPackage ./frida.nix {};

  http_ece = callPackage ./http_ece.nix {};

  Mastodon = callPackage ./Mastodon.nix {
    inherit http_ece;
  };

  lesscpy = callPackage ./lesscpy.nix {};

  pry = callPackage ./pry.nix {};

  priority = callPackage ./priority.nix {};
}
