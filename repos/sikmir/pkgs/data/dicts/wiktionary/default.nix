{ callPackage }:

{
  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2021-09-03";
    hash = "sha256-XQAJzZ/tN/gWj50NW21CQbAX+vAt+X52XqXHMM9tDB4=";
  };

  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2021-09-01";
    hash = "sha256-JLfzochNxA9ALUL7J3QD5AQxEyq7Tnd3Prfc8HNoqr8=";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2021-08-30";
    hash = "sha256-pZk1/5jb5Rgq/6VrpKIAQsRn0H/kR2n11A4m3aotOrI=";
  };

  ru-be = callPackage ./base.nix {
    lang = "ru-be";
    version = "2021-08-21";
    hash = "sha256-wGRbD0s0GECqdxJtBlw+geQHSArT4oGjn9tWSPhRPSg=";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2021-08-21";
    hash = "sha256-lf7vvMBEMoreljU+HVpLhCbjhC+lTRRV6Km7SdActbU=";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2021-08-21";
    hash = "sha256-xfOd0NRoQ2T3ygK92hfxtI7u56MNSqOtl8hxwm+032w=";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2021-08-21";
    hash = "sha256-G6fwC6KB018wlF8wlBEkXTMg5xl4kXM8WyTrTx8S8og=";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2021-08-21";
    hash = "sha256-udCgUNM11b7b4py6r+UGTU8j3KwQ6Sg1HPS++bnunLg=";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2021-08-21";
    hash = "sha256-iQwwQqyvg64RBannVVsrLFyS7/rUYobMBpm2zSNELv8=";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2021-08-21";
    hash = "sha256-uf9JakgRcZswuUHo9Gt6xM3p23KTxp78evRdk08BLrw=";
  };
}
