{ callPackage }:

{
  ural-fed-district = callPackage ./base.nix {
    pname = "ural-fed-district";
    version = "2021-02-16";
    sha256 = "13qlrm4j73ngzm3nly10lq48smm9z7b0620zqvxcxpvnj0zx1bl1";
  };

  northwestern-fed-district = callPackage ./base.nix {
    pname = "northwestern-fed-district";
    version = "2021-02-16";
    sha256 = "1pal12kfkg22iild0jym27fch8g189krkkwpsphlglf1r8544aqf";
  };
}
