{ callPackage }:

{
  pripolarural = callPackage ./base.nix {
    pname = "PripolarUralIMG";
    version = "2011-08-21";
    sha256 = "0jgmn81skr4vq1h0bcxm5647gg4wip74mrq88mr9fi5s0z0v59bf";
  };

  middleural = callPackage ./base.nix {
    pname = "MiddleUral";
    version = "2019-12-26";
    sha256 = "1pal12kfkgi8iild0jym27fch8g189krkkwpsphlglf1r8544aqf";
  };

  guh = callPackage ./base.nix {
    pname = "GUH";
    version = "2018-01-19";
    sha256 = "03ylyyng5qhp202pq0b0lmsnh6yigcbmkm3yblgawsz7crz7xwl4";
  };

  manpup = callPackage ./base.nix {
    pname = "MANPUP";
    version = "2018-01-19";
    sha256 = "19546w5752y21i9z6r4d5sy3b09dqn3plnyhj4z8aar00p7j1dal";
  };

  polarural = callPackage ./base.nix {
    pname = "PolarUral";
    version = "2010-12-05";
    sha256 = "1hdw8a565c1f65iv26y04sjw90q5kcqjw2q6jj10r1aksx0vwlxx";
  };
}
