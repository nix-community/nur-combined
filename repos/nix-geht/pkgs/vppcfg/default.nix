{ pkgs,
vpp_papi }:

with pkgs.python3Packages;
buildPythonPackage rec {
  pname = "vppcfg";
  version = "0.0.2";
  src = pkgs.fetchFromGitHub {
    owner = "pimvanpelt";
    repo = "vppcfg";
    rev = "c10b7bbabb8d65e4cfa83a4b88de95bb4370e933";
    hash = "sha256-YFfLUBxdC30YbmB0EQKXOZE5a+hOW2hSI641poVfybM=";
  };

  propagatedBuildInputs = [ requests yamale netaddr vpp_papi ];
}
