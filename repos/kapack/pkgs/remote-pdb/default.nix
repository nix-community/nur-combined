{ lib, pkgs, fetchurl, python3Packages}:

python3Packages.buildPythonPackage rec {
  pname = "remote-pdb";
  version = "2.0.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/be/de/d8923fb412117ea28a89751cb5712c68ad47326cbe15bdcf257022557f93/remote-pdb-2.0.0.tar.gz";
    sha256 = "ad38f36f539b22be820f94062618366d5d3461115c1605b11679dba75f94ee62";
  };

  LC_ALL = "en_US.UTF-8";

  doCheck = false;
  meta = with lib; {
    longDescription = ''
     .'';
    description = ''Remote vanilla PDB (over TCP sockets).'';
    homepage    = "https://github.com/ionelmc/python-remote-pdb/blob/master/setup.py";
    platforms   = platforms.unix;
    license     = licenses.bsd2;
    broken      = false;
  };
}
