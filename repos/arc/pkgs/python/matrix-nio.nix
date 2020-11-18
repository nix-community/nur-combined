{ lib, pythonPackages, fetchFromGitHub, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "matrix-nio";
    rev = version;
    sha256 = "190xw3cvk4amr9pl8ip2i7k3xdjd0231kn2zl6chny5axx22p1dv";
  };

  postPatch = lib.optionalString (!enableOlm) ''
    substituteInPlace setup.py \
      --replace 'python-olm>=3.1.0' ""
  '';

  doCheck = enableOlm;

  propagatedBuildInputs = with pythonPackages; [
    attrs
    future
    h11
    h2
    pycryptodome
    sphinx
    Logbook
    jsonschema
    unpaddedbase64
  ] ++ lib.optionals (!pythonPackages.python.isPy2) [ aiohttp aiofiles ]
    ++ lib.optionals enableOlm [ olm peewee atomicwrites cachetools ];

  passthru = {
    inherit enableOlm;
  };
}
