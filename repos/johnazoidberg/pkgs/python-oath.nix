{ lib, python36Packages }:
python36Packages.buildPythonApplication rec {
  pname = "oath";
  version = "1.4.1";

  src = python36Packages.fetchPypi {
    inherit pname version;
    sha256 = "1nrhpv025cv0pgpbzlspnrjzwqhvmfmx9r5ck2gc8mpygnnrxxb0";
  };

  meta = with lib; {
    description = "Python implementation of HOTP, TOTP and OCRA algorithms from OATH";
    homepage = https://github.com/bdauvergne/python-oath;
    license = licenses.bsd3;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}
