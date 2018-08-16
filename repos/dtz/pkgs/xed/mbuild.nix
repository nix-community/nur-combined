{ stdenv, fetchFromGitHub, pythonPackages }:

pythonPackages.buildPythonPackage rec {
  name = "mbuild-${version}";
  version = "2018-05-17";

  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "mbuild";
    rev = "1651029643b2adf139a8d283db51b42c3c884513";
    sha256 = "1hdrzdyldszr4czfyw45niza4dyzbc2g14yskrz1c7fjhb6g4f6p";
  };

  meta = with stdenv.lib; {
    description = "python-based build system used for building XED";
    homepage = https://github.com/intelxed/mbuild;
    license = licenses.apsl20;
  };
}
