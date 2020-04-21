{ callPackage }:

{
  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2020-04-15";
    sha256 = "05a1f5b531a76g7wyq2lpdw9zlhjc3c940agvjfwi03ix8af91l3";
  };

  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2020-04-17";
    sha256 = "06p1487w2gk2xjfvdbgixvxp14nzkjx80w4hmzl7chwbachav22y";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2020-04-20";
    sha256 = "1ck9fl8bkm62h7m97sj4fdrkfvjvd15r1lisz3yahh52mrsj60f4";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2020-04-07";
    sha256 = "14pxk9p0n3ps2s6hpxn6ly5by1b5169vbx5qsia31cbywgil9wj7";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2020-04-07";
    sha256 = "1b8vcybih4d7v21lb98fs135kcfbpxz4k28khd6bj9r6k0wl2awk";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2020-04-07";
    sha256 = "1fd8kaisfwa6515296i44jdm63msdy3ym8md72sk90inv66lz320";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2020-04-07";
    sha256 = "0z34y7fyz03ixf45s975ar2fnnykbd3d2src6r30w3y9spg34d2z";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2020-04-07";
    sha256 = "0ji2dki6k8pgscgkdfhz98il31swb5cffl481f80kbimwjbl2hwn";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2020-04-07";
    sha256 = "0bzcn6ygs47baf8ii0ff6zwv646jy6klx35p38c8w27f9gkb8b1m";
  };
}
