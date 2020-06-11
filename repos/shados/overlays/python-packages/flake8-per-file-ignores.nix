{ stdenv, fetchPypi, buildPythonPackage, flake8
, pathmatch ? null, typing ? null, six ? null, fetchurl ? null
}:

let

  _pathmatch = if isNull pathmatch then
      assert !isNull typing;
      assert !isNull six;
      assert !isNull fetchurl;
      buildPythonPackage rec {
        name = "${pname}-${version}";
        pname = "pathmatch";
        version = "0.2.1";

        # src = fetchPypi {
        #   inherit pname version;
        #   sha256 = "b35db907d0532c66132e5bc8aaa20dbfae916441987c8f0abd53ac538376d9a7";
        # };
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/10/f5/b9823d0042bbff98bd5cf3f5a19ccadd6d0c41034f9bfb6639baed18595c/pathmatch-0.2.1.zip";
          sha256 = "b35db907d0532c66132e5bc8aaa20dbfae916441987c8f0abd53ac538376d9a7";
        };

        doCheck = false;
        buildInputs = [];
        propagatedBuildInputs = [
          six
          typing
        ];
        meta = with stdenv.lib; {
          maintainer = with mainters; [ arobyn ];
          homepage = "https://github.com/demurgos/py-pathmatch";
          license = licenses.mit;
          description = "Path matching utilities";
        };
      }
    else
      pathmatch;

in

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "flake8-per-file-ignores";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "4ee4f24cbea5e18e1fefdfccb043e819caf483d16d08e39cb6df5d18b0407275";
  };
  doCheck = false;
  buildInputs = [];
  propagatedBuildInputs = [
    flake8
    _pathmatch
  ];
  meta = with stdenv.lib; {
    maintainer = with mainters; [ arobyn ];
    homepage = "https://github.com/snoack/flake8-per-file-ignores";
    license = licenses.mit;
    description = "Ignore individual error codes per file with flake8";
  };
}
