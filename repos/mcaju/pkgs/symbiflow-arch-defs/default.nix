{ pkgs
, lib
, devices ? [ "xc7a50t" "xc7a100t" "xc7a200t" "xc7z010" "xc7z020" ]
}:

let
  buildNum = "175";
  buildDate = "20210305-000130";
  commit = "098fe2e8";

  bin = pkgs.callPackage ./bin.nix {
    inherit buildNum buildDate commit;
    sha256 = "06lnk93rwxd93dp05wv5225dagrw3f7n7zwizvzipk5pfhqx5ixw";
  }; 

  devicePkgs = {
    "xc7a50t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device  = "xc7a50t";
      sha256 = "1jq91r23ay7vf08ich69n4l8kkq7nn5rc7bfgrgkqs5chmmsx41k";
    };
    "xc7a100t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7a100t";
      sha256 = "0s5q4dgwnzyvnclcxr75g37xma1vhdmd47bswkf8c82hvg9cpqzs";
    };
    "xc7a200t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7a200t";
      sha256 = "1wlx3qqdc7jn2l2w3cd1kqj0686j5f267abvf4qiw79y7zxgg71d";
    };
    "xc7z010" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7z010";
      sha256 = "0qfffkxcikis2ljasmmc6f0s2y3dyhaljah298wxxi89388fcq9b";
    };
    "xc7z020" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7z020";
      sha256 = "14agjmmw0w8vjqdyg932ynzzgv10hq8j32di0lnzdwz4dcrvl99p";
    };
  };
  
  devices_ = with lib.attrsets; attrVals devices devicePkgs;

in

pkgs.callPackage ./wrapper.nix {
  inherit buildDate commit bin;
  devices = devices_;
}
