{ buildPythonPackage, stdenv, python, fetchFromGitHub }:

buildPythonPackage {
  pname = "weechat-matrix";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "c02fa75d4f9b2a5b6fd69ef6f25502891be317b4";
    sha256 = "0pgqx4c2phip2ga6dyvf3hqrx09gc3gwjriijfwwayl40526wk4j";
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
