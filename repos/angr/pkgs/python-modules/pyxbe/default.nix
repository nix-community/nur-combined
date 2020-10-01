{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, pkgs
}:

buildPythonPackage rec {
  pname = "pyxbe";
  version = "unstable-2020-04-26";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "mborgerson";
    repo = pname;
    rev = "a41649a32fd77f949b07a8c174feef9fa9bc089b";
    sha256 = "1slkcd2p2k3aydkqspbz8cmn99chxk6swnrgy98s5kclz1aj70lb";
  };

  preCheck = ''
    sed -i "s/'xbefiles'/'tests', 'xbefiles'/g" tests/test_load.py
  '';

  meta = with pkgs.lib; {
    description = "Library to work with .xbe files";
    homepage = "https://github.com/mborgerson/pyxbe";
    license = licenses.mit;
    maintainers = [ maintainers.pamplemousse ];
  };
}
