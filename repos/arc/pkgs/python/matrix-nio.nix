{ lib, pythonPackages, fetchFromGitHub, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "0mgb9m3298jvw3wa051zn7vp1m8qriys3ps0qn3sq54fndljgg5k";
  };

  postPatch = lib.optionalString (!enableOlm) ''
    substituteInPlace setup.py \
      --replace 'python-olm>=3.1.0' ""
  '';

  doCheck = enableOlm;

  propagatedBuildInputs = with pythonPackages; [
    attrs
    future
    peewee
    h11
    h2
    atomicwrites
    pycryptodome
    sphinx
    Logbook
    jsonschema
    unpaddedbase64
    cachetools
  ] ++ lib.optionals (!pythonPackages.python.isPy2) [ aiohttp aiofiles ]
    ++ lib.optional enableOlm olm;

  passthru = {
    inherit enableOlm;
  };
}
