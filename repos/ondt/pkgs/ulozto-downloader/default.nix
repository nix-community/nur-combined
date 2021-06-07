{ lib, fetchFromGitHub, python3Packages, tor }:

python3Packages.buildPythonApplication rec {
  pname = "ulozto-downloader";
  version = "2.6.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "08z1pm6nk991b7hpsjqwir5dayzm8brxms63wdif25y3k7l3idf4";
  };

  # src = fetchFromGitHub {
    # owner = "setnicka";
    # repo = "ulozto-downloader";
    # rev = version;
    # sha256 = "19sbgssapq5m4g1bhzzmwyym7igrxml51hwz2rvj3ld8ypyk3cdk";
  # };
  
  patches = [ ./tensorflow.patch ];

  propagatedBuildInputs = with python3Packages; [
    tkinter
    tensorflow
    
    requests
    pillow
    ansicolors
    numpy
    pysocks
    stem
  ] ++ [
    tor
  ];

  doCheck = false;

  meta = with lib; {
    description = "Paralelní stahovač z Ulož.to s automatickým louskáním CAPTCHA kódů";
    homepage = "https://github.com/setnicka/ulozto-downloader";
    license = licenses.mit;
    # maintainers = with maintainers; [  ];
  };
}
