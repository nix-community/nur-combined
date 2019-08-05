{ lib, pythonPackages, fetchFromGitHub, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin && !lib.isNixpkgsStable
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "09kcqv5wjvxnx3ligql6k7h5rshsim97y356c9k01d9hpv1lbccb";
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
