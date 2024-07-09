{ lib
, fetchFromGitHub
, fetchpatch
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "commix";
  version = "3.9";

  src = fetchFromGitHub {
    owner = "commixproject";
    repo = "commix";
    rev = "25fa4ab435608e02afcd3f33792bb8f6daeaff86";
    sha256 = "sha256-gCQuLezEamrqYF531uifCmQRc3xUxuYhzoFTPj0Niyc=";
  };
  # patches = [
  #   (fetchpatch {
  #     url = "https://github.com/commixproject/commix/commit/25fa4ab435608e02afcd3f33792bb8f6daeaff86.patch";
  #     sha256 = "sha256-dX2M6/boAKzu9iOMeTtbBir3PQDEuHLqTpSxKX5Gjzg=";
  #   })
  # ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace "3.9-stable" "3.9"
  '';

  propagatedBuildInputs = with python3Packages; [ tornado python-daemon ];

  # checkInputs = with python3Packages; [ six ];

  checkPhase = ''
    python3 commix.py --smoke-test
  '';

  doCheck = true;

  meta = with lib; {
    description = "Automated All-in-One OS Command Injection Exploitation Tool";
    license = licenses.gpl3Only;
    homepage = "https://commixproject.com/";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
