{ lib, fetchPypi, buildPythonApplication, rclone, p7zip }:

buildPythonApplication rec {
  pname = "git-remote-rclone";
  version = "0.1";

  src = fetchPypi {
    inherit version;
    pname = lib.replaceStrings [ "-" ] [ "_" ] pname;
    sha256 = "sha256-zCOnHWvV74iQleEKrqye54R/QpUzXHL4pEX6uP76rRE=";
  };

  propagatedBuildInputs = [ rclone p7zip ];

  meta = with lib; {
    description = "Git remote helper for rclone-supported services";
    homepage = "https://github.com/datalad/git-remote-rclone";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
