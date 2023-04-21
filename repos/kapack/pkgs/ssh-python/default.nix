{ python3Packages, cmake, libssh2, openssl, zlib }:

python3Packages.buildPythonPackage rec {
  pname = "ssh-python";
  version = "0.10.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-ZFlypiAbOGvHs4CQFO4p1JqB0DVCIgqUrPBSykbF+Mg=";
  };
  # We don't want to build with CMake, just include it for the libssh2 bindings.
  dontUseCmakeConfigure = true;
  nativeBuildInputs = [ cmake ];

  SYSTEM_LIBSSH2 = "1";
  buildInputs = [ libssh2 openssl zlib ];
}
