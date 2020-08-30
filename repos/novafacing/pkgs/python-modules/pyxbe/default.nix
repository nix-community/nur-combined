{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, pkgs
}:

buildPythonPackage rec {
  pname = "pyxbe";
  version = "unstable-2020-05-28";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "mborgerson";
    repo = pname;
    rev = "a41649a32fd77f949b07a8c174feef9fa9bc089b";
    sha256 = "0ww5kbfqmj4m3fbcmp8rx22php7hargykclja7spjbqjs303hxhv";
  };

  preCheck = ''
    ls -lahR
    # sed -i "s/'xbefiles'/'tests', 'xbefiles'/g" tests/test_load.py
    echo "HELLO"
    ls -lahR
  '';

  meta = with pkgs.lib; {
    description = "Library to work with .xbe files";
    homepage = "https://github.com/mborgerson/pyxbe";
    license = licenses.mit;
    maintainers = [ maintainers.pamplemousse ];
  };
}
