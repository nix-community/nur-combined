{ buildPythonPackage, stdenv, python, fetchFromGitHub }:

buildPythonPackage {
  pname = "weechat-matrix";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "weechat-matrix";
    rev = "15b2d99047071fe0e1e5080b066aedd59c062b24";
    sha256 = "1k0kqy6myq3ijwd88pqc50l61blcs1swmm8lrz8jk9bxq82jviwc";
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
