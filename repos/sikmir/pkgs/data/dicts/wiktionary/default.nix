{ callPackage }:

{
  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2020-07-08";
    sha256 = "0rxq07gyhnpx1yfmmx75vzn716xai6l64xph8appxhww66j70k1w";
  };

  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2020-07-10";
    sha256 = "0iz1181m5mx7344r44pzmcqf8qz43s25j1sc61g9sq5qpzyr2jv3";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2020-07-06";
    sha256 = "049hslcrspw48abmkf7hhxymcv46xskk87qddwv4lkm8kkjahk47";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2020-07-07";
    sha256 = "0kb8m8jr0az41fyldfyyq3z5xfmzjk1i8qkgi3877f46sgc9rrka";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2020-07-07";
    sha256 = "133qiq8nnxlnnj1a2r3wgkffcqv4j3w02bj5abc26xigiq1a8ysd";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2020-07-07";
    sha256 = "1y0nrjklqm116wfznn29nsdx3c3pv9d7ivb8nh83pzc7ma1ynha3";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2020-07-07";
    sha256 = "1qm4zcql86wvfc2lcybzgxnlqq9pirx2691dk1rrvdfimzvnrbvk";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2020-07-07";
    sha256 = "0kv713yyr7s62hz5d6500pjqy8c3nlbg61mwmri4x34rjyqmpimd";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2020-07-07";
    sha256 = "09jrk02z4ir71nznllwk1j3lclgnhbpjvcz6bm7cp92qm8ach95q";
  };
}
