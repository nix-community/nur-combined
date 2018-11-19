{ callPackage }:

rec {
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

  remote-pdb = callPackage ./remote-pdb.nix {};
}
