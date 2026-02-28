{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  lib60870,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iec104_client_control";
  version = "1.0.1-unstable-2026-02-26";

  src = fetchFromGitHub {
    owner = "PVKonovalov";
    repo = "iec104_client_control";
    rev = "975971dfd35dd45e7662fcb88393a06b7cccf5e8";
    hash = "sha256-tQvfX9jN4UTL/IyHRtqDTIu5pB5+ZomEqyo8bSC3EtI=";
  };

  postPatch = ''
    sed -i '/LIB_60870/d' CMakeLists.txt
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
