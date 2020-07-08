{ callPackage }:
let
  version = "2.4.2";
in
{
  cambridge = callPackage ./base.nix {
    pname = "cambridge";
    inherit version;
    filename = "stardict-Cambridge_Advanced_Learners_Dictionary_3th_Ed-${version}.tar.bz2";
    description = "Cambridge Advanced Learners Dictionary 3th Ed. (En-En)";
    sha256 = "0mqrf5fr6hx3bjy1brsggmkrii2xf497jkaj6zf1hjxnp0ijswgr";
  };

  macmillan = callPackage ./base.nix {
    pname = "macmillan";
    inherit version;
    filename = "stardict-Macmillan_English_Dictionary-${version}.tar.bz2";
    description = "Macmillan English Dictionary (En-En)";
    sha256 = "1xg4xvxnni5vc371sd0bvskl1vly6p62q3c8r36bd2069ln7jy8r";
  };

  webster = callPackage ./base.nix {
    pname = "webster";
    inherit version;
    filename = "stardict-Webster_s_Unabridged_3-${version}.tar.bz2";
    description = "Webster's Third New International Dictionary, Unabridged (En-En)";
    sha256 = "1gj33px44d4ywhnxv7x5hxvh43f8m7skwmhvc62ld0c50blrqi7a";
  };
}
