{ pkgs
, lib
, prjxray-db
, python3Packages
, vtr
, yosys
, yosys-symbiflow-plugins
, devices ? [ "xc7a50t" "xc7a100t" "xc7a200t" "xc7z010" "xc7z020" ]
}:

let
  buildNum = "287";
  buildDate = "20210609-000542";
  commit = "2c411431";

  bin = pkgs.callPackage ./bin.nix {
    inherit buildNum buildDate commit;
    inherit prjxray-db python3Packages vtr yosys yosys-symbiflow-plugins;
    sha256 = "1bm1mnjxarb8hzw4k9s868m9ain7mdi8iqdggjnpax63ac0lfa5p";
  }; 

  devicePkgs = {
    "xc7a50t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device  = "xc7a50t";
      sha256 = "1zxqw34gyy2hpcffky69vv997k2hs318yv5a0zp3zlssj25qb6nm";
    };
    "xc7a100t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7a100t";
      sha256 = "06yhdd0y35kn0j7vffn0q8rjzqrzx0yikv507ry0cw88gnlf39xq";
    };
    "xc7a200t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7a200t";
      sha256 = "09h2kh25gfj5d8x4nmq1scab5yjw8f59v8xsvhixcsilqxfh0pa8";
    };
    "xc7z010" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7z010";
      sha256 = "0854d1ppi7hrycdwgffg68lsavllvdcpzn1670k9b7h073cf7cgy";
    };
    "xc7z020" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7z020";
      sha256 = "0i2ppc1yw9n6xwcl7phac2yjwx3qmj18237fzp1wj08s17l05a0p";
    };
  };
  
  devices_ = with lib.attrsets; attrVals devices devicePkgs;

in

pkgs.callPackage ./wrapper.nix {
  inherit buildDate commit bin;
  devices = devices_;
}
