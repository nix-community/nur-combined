{ lib, stdenv, fetchFromGitHub, cmake, cmocka }:

stdenv.mkDerivation (finalAttrs: {
  pname = "MQTT-C";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "LiamBindle";
    repo = "MQTT-C";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TmqEekdAyxueY0A1a96eyADBpLe+AWd6xMQP3tF6968=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ cmocka ];

  cmakeFlags = [
    (lib.cmakeBool "MQTT_C_INSTALL_EXAMPLES" true)
    (lib.cmakeBool "MQTT_C_TESTS" true)
  ];

  doCheck = false;

  checkPhase = ''
    ./tests
  '';

  meta = with lib; {
    description = "A portable MQTT C client for embedded systems and PCs alike";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
