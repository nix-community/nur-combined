{ lispPackages, fetchurl, ... }:

lispPackages.buildLispPackage {

  baseName = "s-dot";
  version = "1.2";

  buildSystems = [ ];

  description = "s-dot";

  deps = [ ];

  src = fetchurl {
    url = "https://martin-loetzsch.de/S-DOT/s-dot.tar.gz";
    sha256 = "1lq0hj143gqjl55k93g7bqsjbwp127ybcwdv28y809zflsnsscg1";
  };
}
