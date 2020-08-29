{ lib
, buildPythonPackage
, fetchPypi
, pbr
, six
, wrapt
}:
let 
  pyModuleDeps = [
    pbr
    six
    wrapt
  ];
in
buildPythonPackage rec {
  pname = "debtcollector";
  version = "2.2.0";

  src = fetchPypi {
    pname = "debtcollector";
    inherit version;
    sha256 = "0ab8ic9bk644i8134z044kpcf6pvawqf4rq4xgv1p11msbs82ybq";
  };
  
  buildInputs = pyModuleDeps;
  propagatedBuildInputs = pyModuleDeps;
  
  # Needs internet connection
  doCheck = false;

  meta = with lib; {
    description = "Python library to collect your technical debt";
    license = licenses.asl20;
    longDescription = ''
      A collection of Python deprecation patterns and strategies that help you
      collect your technical debt in a non-destructive manner. The goal of this
      library is to provide well documented developer facing deprecation
      patterns that start of with a basic set and can expand into a larger set
      of patterns as time goes on. The desired output of these patterns is to
      apply the warnings module to emit DeprecationWarning or
      PendingDeprecationWarning or similar derivative to developers using
      libraries (or potentially applications) about future deprecations.
    '';
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
