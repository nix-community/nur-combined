{ callPackage }:

{
  pripolarural = callPackage ./base.nix {
    pname = "PripolarUralIMG";
    version = "2011-08-21";
    hash = "sha256-bqWywQe6RJdyRQjnSs6NnLx3iCm1swVgwJvkqQOy9Uk=";
  };

  middleural = callPackage ./base.nix {
    pname = "MiddleUral";
    version = "2019-12-26";
    hash = "sha256-DitCCsrB0Ufh1ZfPmWdC4SHI3BHVS9BojCi+6aYIVN0=";
  };

  guh = callPackage ./base.nix {
    pname = "GUH";
    version = "2018-01-19";
    hash = "sha256-51WV39SyR4nIQOywvmOCO6ej+1HVMDTJ0DILkBzjj5g=";
  };

  manpup = callPackage ./base.nix {
    pname = "MANPUP";
    version = "2018-01-19";
    hash = "sha256-VLUgzwUgK4U+kdBbeofFLYE1vC6NZPNTDMKLcgo3pKQ=";
  };

  polarural = callPackage ./base.nix {
    pname = "PolarUral";
    version = "2010-12-05";
    hash = "sha256-vVO+QddThQyClAYLLjGbBYPEpSbAG7FjMS6wYopCvME=";
  };
}
