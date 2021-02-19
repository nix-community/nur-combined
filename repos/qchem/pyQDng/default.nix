{ lib, buildPythonPackage, fetchFromGitLab, numpy, protobuf } :

buildPythonPackage {
  pname = "pyQDng";
  version = "0.9";

  src = fetchFromGitLab {
    domain = "gitlab.fysik.su.se";
    owner = "markus.kowalewski";
    repo = "pyqdng";
    rev = "98e30612a27618e60e49b18b3eee83ca9bd9c47b";
    sha256 = "0n54hyywihd4gvfi816wh2s486y9i4wq6mflq472b9i83yb79fz4";
  };

  propagatedBuildInputs = [ numpy protobuf ];

  meta = with lib; {
    description = "Python package for handling QDng binary files";
    homepage = "https://gitlab.fysik.su.se/markus.kowalewski/pyqdng";
    maintainers = [ maintainers.markuskowa ];
    license = [ licenses.gpl2Only ];
    platforms = platforms.all;
  };
}
