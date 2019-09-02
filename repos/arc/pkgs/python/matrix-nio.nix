{ lib, pythonPackages, fetchFromGitHub, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin && !lib.isNixpkgsStable
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "1nbpldjbrd7chfdfrmqmb621k3jrzn7arb339lw3a266iy0s8nnv";
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
  ] ++ lib.optional (!pythonPackages.python.isPy2) aiohttp
    ++ lib.optional enableOlm olm;

  passthru = {
    inherit enableOlm;
  };
}
