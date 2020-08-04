{ lib, pkgs, stdenv, python3Packages, fetchFromGitLab }:

let
  pname = "pmbootstrap";
  version = "1.20.0";
in

python3Packages.buildPythonApplication rec {
  inherit pname version;

  src = fetchFromGitLab {
    owner = "postmarketOS";
    repo = pname;
    rev = version;
    sha256 = "02d0amhni8bk7f1xgvlyxjd7y4wfqy45wkw2snvy100rgacmxd8z";
  };

  # building with tests fails:
  # ```
  # The directory '/homeless-shelter/.cache/pip/http' or its parent directory is not owned by the current user and the cache has been disabled.
  # ```
  doCheck = false;

  propagatedBuildInputs = with pkgs; [ git python3 openssl proot ];

  meta = with stdenv.lib; {
    homepage = "https://gitlab.com/postmarketOS/pmbootstrap";
    description = "Sophisticated chroot/build/flash tool to develop and install postmarketOS";
    # I'm not in nixpkgs maintainers yet
    maintainers = with maintainers; [ ];
    license = licenses.gpl3;
  };

}
