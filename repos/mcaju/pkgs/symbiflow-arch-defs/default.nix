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
      sha256 = "e1b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca485991b7852b855";
    };
    "xc7a100t" = pkgs.callPackage ./mkdevice.nix {
      inherit buildNum buildDate commit;
      device = "xc7a100t";
      sha256 = "0s5q4dgwnzyvnclcxr75g37xma1vhdmd47bswkf8c82hvg9cpqzs";
    };
    "xc7a200t" = pkgs.callPackage {
      inherit buildNum buildDate commit;
      device = "xc7a200t";
      sha256 = "e3a0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    };
    "xc7z010" = pkgs.callPackage {
      inherit buildNum buildDate commit;
      device = "xc7z010";
      sha256 = "e2a0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    };
    "xc7z020" = pkgs.callPackage {
      inherit buildNum buildDate commit;
      device = "xc7z020";
      sha256 = "d3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    };
  };
  
  devices_ = (with lib.attrsets; attrVals devices devicePkgs);

in

pkgs.callPackage ./wrapper.nix {
  inherit buildDate commit bin;
  devices = devices_;
}
