{ lib, pythonPackages, fetchFromGitHub, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "0pq5i6ks3pck2kq9m4p3pw9hbvkzs27xkyv68mjnfc6chp2g2mg9";
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
  ] ++ lib.optional (!pythonPackages.python.isPy2) aiohttp
    ++ lib.optional enableOlm olm;

  passthru = {
    inherit enableOlm;
  };
}
