{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  lib60870,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iec104_client_control";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "PVKonovalov";
    repo = "iec104_client_control";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RrQtDehRxQFNbXelIE2KwLH6iMj29CuMmnEjjgHX+hM=";
  };

  postPatch = ''
    sed -i '/LIB_60870/d' CMakeLists.txt
    sed -i '27i #include <chrono>' main.cpp
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ lib60870 ];

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev lib60870}/include/lib60870";

  installPhase = ''
    runHook preInstall
    install -Dm755 iec104_client_control -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "IEC-60870-5-104 Client Control Program";
    homepage = "https://github.com/PVKonovalov/iec104_client_control";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "iec104_client_control";
  };
})
