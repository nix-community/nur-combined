{ lib
, fetchPypi
, python3Packages
, poetry-core
, poetry-dynamic-versioning
}:

python3Packages.buildPythonPackage rec {
  pname = "tbc-video-export";
  version = "0.1.5";
  format = "pyproject";

  src = fetchPypi {
    inherit version;
    pname = builtins.replaceStrings [ "-" ] [ "_" ] pname;
    sha256 = "sha256-KPb+WrnJtn7esDu2XTRz/ZSspXw5V9CXrHpiJZMbFdo=";
  };

  buildInputs = [
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = with python3Packages; [
    typing-extensions
  ];

  meta = with lib; {
    description = "Tool for exporting S-Video and CVBS-type TBCs to video files.";
    homepage = "https://github.com/JuniorIsAJitterbug/tbc-video-export";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.all;
  };
}
