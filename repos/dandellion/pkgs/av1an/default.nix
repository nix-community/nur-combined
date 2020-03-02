{lib, fetchFromGitHub, python3, python3Packages, ffmpeg-full, libaom }:

let
  scenedetect = python3Packages.buildPythonPackage rec {
    pname = "scenedetect";
    version = "0.5.1.1";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "097y3v7rjq75rpzysxksqjhbk8m3g7wn46spc380zjhy3if6nlhn";
    };
  };

  opencv-python = python3Packages.buildPythonPackage rec {
    pname = "opencv-python";
    version = "4.2.0.32";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "19xm24vgfqis0bqrg5fc5jxf5yr1md5y49kb7q3792gihykl6yz2";
    };
  };

  pythonEnv = python3.withPackages (pythonPackages: [
    pythonPackages.numpy
    scenedetect
    opencv-python
    pythonPackages.tqdm
    pythonPackages.psutil
  ]);

in
  python3Packages.buildPythonApplication rec {
    pname = "av1an";
    version = "1.6";

    src = fetchFromGitHub {
      owner = "master-of-zen";
      repo = "AV1an";
      rev = "${version}";
      sha256 = "19xm24vgfqis0bqrg5fc5jxf5yr1md5y49kb7q3792gihykl6yz3";
    };

    buildInputs = [ pythonEnv ffmpeg-full libaom ];

    meta.broken = true;

  }
