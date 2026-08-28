{
  buildPythonPackage,
  fetchPypi,
  lib,
  cryptography,
}:

buildPythonPackage (finalAttrs: {
  pname = "cryptography_vectors";
  # The test vectors must have the same version as the cryptography package:
  version = cryptography.version;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-jJ1a+tpkemyTfGOSyXXyBLVAwx8l/UrNkl7A4YC+Cvo=";
  };

  # No tests included
  doCheck = false;

  meta = with lib; {
    description = "Test vectors for the cryptography package";
    homepage = "https://cryptography.io/en/latest/development/test-vectors/";
    # Source: https://github.com/pyca/cryptography/tree/master/vectors;
    license = with licenses; [
      asl20
      bsd3
    ];
    maintainers = with maintainers; [ primeos ];
  };
})
