{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cmocka,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "MQTT-C";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "LiamBindle";
    repo = "MQTT-C";
    tag = "v${finalAttrs.version}";
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

  meta = {
    description = "A portable MQTT C client for embedded systems and PCs alike";
    homepage = "https://github.com/LiamBindle/MQTT-C";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
