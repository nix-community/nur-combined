{ python3Packages, cmake, libssh2, openssl, zlib }:

python3Packages.buildPythonPackage rec {
  pname = "ssh2-python";
  version = "0.27.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-plsU/0S3oFzpDHCvDeZE0wwdB+dtrFDfjg19K5QJYjs=";
  };

  # We don't want to build with CMake, just include it for the libssh2 bindings.
  dontUseCmakeConfigure = true;
  nativeBuildInputs = [ cmake ];

  SYSTEM_LIBSSH2 = "1";

  buildInputs = [ libssh2 openssl zlib ];
}

