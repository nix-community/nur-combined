{ lib, python38Packages, fetchFromGitHub }:

python38Packages.buildPythonPackage rec {
  pname = "traffic";
  version = "6504a8ac02f362b76a0bd9027b19d79072f0e6f4";
  format = "pyproject";
 
  src = fetchFromGitHub {
    owner = "meain";
    repo = "traffic";
    rev = version;
    sha256 = "sha256:1fr0zcw9id7nhdf3pawd6aw0jrfxa9qnf4i8gcf2lsyfg9c6m8xz";
  };

  # nativeBuildInputs = [ python38Packages.psutil ];
  propagatedBuildInputs = [ python38Packages.psutil ];

  meta = with lib; {
    description = "View network up/down speeds and usage";
    homepage = "https://github.com/meain/trraffic";
    license = licenses.mit;
  };
}
