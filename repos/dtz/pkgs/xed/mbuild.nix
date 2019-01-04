{ stdenv, fetchFromGitHub, pythonPackages }:

pythonPackages.buildPythonPackage rec {
  name = "mbuild-${version}";
  version = "2018-12-20";

  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "mbuild";
    rev = "176544e1fb54b6bfb40f596111368981d287e951";
    sha256 = "113sl3iy3j6f708syip3j8x9gy877vncwxi7p0wn998yj25mswac";
  };

  meta = with stdenv.lib; {
    description = "python-based build system used for building XED";
    homepage = https://github.com/intelxed/mbuild;
    license = licenses.apsl20;
  };
}
