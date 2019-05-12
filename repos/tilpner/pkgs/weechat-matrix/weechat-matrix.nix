{ buildPythonPackage, stdenv, python, fetchFromGitHub }:

buildPythonPackage {
  pname = "weechat-matrix";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "c1cfc4a8e4a67989d526a2c9142575e447f88cd7";
    sha256 = "0q16xr1lfc7qybm3ny7clb4gpmv4vknsppmaaafza6xvysvnm4r6";
  };

  passthru.scripts = [ "matrix.py" ];

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out/share
    cp $src/main.py $out/share/matrix.py
    # cp -r $src/matrix $out/share/
  
    mkdir -p $out/lib/python2.7/site-packages
    cp -r $src/matrix $out/lib/python2.7/site-packages/matrix
  '';

  doCheck = false;
}
