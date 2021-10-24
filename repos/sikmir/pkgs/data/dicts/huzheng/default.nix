{ callPackage }:
let
  version = "2.4.2";
in
{
  cambridge = callPackage ./base.nix {
    pname = "cambridge";
    inherit version;
    filename = "bigdict/stardict-Cambridge_Advanced_Learners_Dictionary_3th_Ed-${version}.tar.bz2";
    description = "Cambridge Advanced Learners Dictionary 3th Ed. (En-En)";
    hash = "sha256-+XEtI7i2SxjcN1JNeRJxXcSYZ31P5xW8XKNDk11xGVc=";
  };

  duden = callPackage ./base.nix {
    pname = "duden";
    inherit version;
    filename = "de/stardict-duden-${version}.tar.bz2";
    description = "Duden - mehr als ein Wörterbuch";
    hash = "sha256-7kF7aWI+HiMU1kplwhAXsFSeJJiGgG6pq3A0Y2ypQ+I=";
  };

  macmillan = callPackage ./base.nix {
    pname = "macmillan";
    inherit version;
    filename = "bigdict/stardict-Macmillan_English_Dictionary-${version}.tar.bz2";
    description = "Macmillan English Dictionary (En-En)";
    hash = "sha256-GXl5LE0GiLbMyIgNLMw1nu5Ap94LNB3OYLtEa/vu5PU=";
  };

  webster = callPackage ./base.nix {
    pname = "webster";
    inherit version;
    filename = "bigdict/stardict-Webster_s_Unabridged_3-${version}.tar.bz2";
    description = "Webster's Third New International Dictionary, Unabridged (En-En)";
    hash = "sha256-6kSc6QKFgUaFYRtWPvWpyA0Cd4eln90t5J40QvodQ74=";
  };
}
