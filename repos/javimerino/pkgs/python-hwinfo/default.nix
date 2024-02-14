{ pkgs }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "python-hwinfo";
  version = "0.1.7";
  # fetchPypi can't be used because pypi is behind the original
  # package https://github.com/rdobson/python-hwinfo . This in turn
  # can't be used because it does not have python3 support.
  # https://github.com/rdobson/python-hwinfo/pull/25 adds support for
  # python3
  src = pkgs.fetchFromGitHub {
    owner = "alexhimmel";
    repo = "rob-python-hwinfo";
    rev = "private/tianxia/CP-41972";
    hash = "sha256-uyaKBtM4f86hu7Ep4NxWf06l3ZeoL3oZAjvErinoLbM=";
  };
  propagatedBuildInputs = with pkgs.python3Packages; [
    paramiko
    prettytable
  ];
}
