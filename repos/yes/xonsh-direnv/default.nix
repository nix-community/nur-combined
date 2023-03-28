{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xonsh-direnv";
  version = "1.6.1";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Nt8Da1EtMVWZ9mbBDjys7HDutLYifwoQ1HVmI5CN2Ww=";
  };

  meta = with lib; {
    description = "Direnv support for the xonsh shell";
    homepage = "https://github.com/74th/xonsh-direnv";
    license = licenses.mit;
  };
}
