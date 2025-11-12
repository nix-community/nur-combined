{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost186,
}:

stdenv.mkDerivation {
  pname = "freeopcua";
  version = "0-unstable-2023-05-30";

  src = fetchFromGitHub {
    owner = "FreeOpcUa";
    repo = "freeopcua";
    rev = "6eac0975636425d2e122b228ca69fea2d30c9ce6";
    hash = "sha256-Vf2+VDiW11aVRY8hAzdQBxQjwDWG/tVzXSw7aU/Gd9c=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost186 ];

  cmakeFlags = [
    (lib.cmakeBool "SSL_SUPPORT_MBEDTLS" false)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  meta = {
    description = "Open Source C++ OPC-UA Server and Client Library";
    homepage = "https://github.com/FreeOpcUa/freeopcua";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
