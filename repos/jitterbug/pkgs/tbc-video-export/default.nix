{ lib
, fetchPypi
, python3Packages
, poetry-core
, poetry-dynamic-versioning
}:

python3Packages.buildPythonPackage rec {
  pname = "tbc-video-export";
  version = "0.1.3";
  format = "pyproject";

  src = fetchPypi {
    inherit version;
    pname = builtins.replaceStrings [ "-" ] [ "_" ] pname;
    sha256 = "sha256-YPWQLG1BOJU20UajiDCKpbXDuQfDDTxbB9rlMuLh2f4=";
  };

  buildInputs = [
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = with python3Packages; [
    typing-extensions
  ];

  meta = with lib; {
    description = "Cross-platform tool for exporting S-Video and CVBS-type TBC files to standard video files.";
    homepage = "https://github.com/JuniorIsAJitterbug/tbc-video-export";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.all;
  };
}
