{ lib, pkgs, fetchFromGitHub, ... }:

with pkgs.pythonPackages;buildPythonPackage rec {
  name = "nltk-${version}";
  version = "3.2.1";
  src = pkgs.fetchurl{
    #url = "mirror://pypi/n/${name}.tar.gz";
    url = "https://pypi.python.org/packages/58/85/8fa6f8c488507aab7d6234ce754bbbe61bfeb8382489785e2d764bf8f52a/${name}.tar.gz";
    sha256 = "0skxbhnymwlspjkzga0f7x1hg3y50fwpfghs8g8k7fh6f4nknlym";

  };
  meta = {
    homepage = http://nltk.org;
    description = "Natural languages Toolkit";
    license = lib.licenses.asl20;
  };
}
