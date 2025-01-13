# based on linyinfeng's package
{
  cmake,
  curl,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pcsclite,
  pkg-config,
  stdenv,
  withDrivers ? true,
  withLibeuicc ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lpac";
  version = "2.2.1";
  src = fetchFromGitHub {
    owner = "estkme-group";
    repo = "lpac";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dxoYuX3dNj4piXQBqU4w1ICeyOGid35c+6ZITQiN6wA=";
  };

  # options:
  # - option(LPAC_DYNAMIC_LIBEUICC "Build and install libeuicc as a dynamic library" OFF)
  # - cmake_dependent_option(LPAC_DYNAMIC_DRIVERS "Build lpac/libeuicc driver backends as a dynamic library" OFF "LPAC_DYNAMIC_LIBEUICC" OFF)
  # - option(LPAC_WITH_APDU_PCSC "Build APDU PCSC Backend (requires PCSC libraries)" ON)
  #   - option(LPAC_WITH_APDU_AT "Build APDU AT Backend" ON)
  #   - option(LPAC_WITH_APDU_AT "Build APDU AT Backend" OFF)
  # - option(LPAC_WITH_APDU_GBINDER "Build APDU Gbinder backend for libhybris devices (requires gbinder headers)" OFF)
  # - option(LPAC_WITH_APDU_QMI "Build QMI backend for Qualcomm devices (requires libqmi)" OFF)
  # - option(LPAC_WITH_APDU_QMI_QRTR "Build QMI-over-QRTR backend for Qualcomm devices (requires libqrtr and libqmi headers)" OFF)
  # - option(LPAC_WITH_APDU_MBIM "Build MBIM backend for MBIM devices (requires libmbim)" OFF)
  # - option(LPAC_WITH_HTTP_CURL "Build HTTP Curl interface" ON)

  cmakeFlags = lib.optionals withDrivers [
    "-DLPAC_DYNAMIC_DRIVERS=on"
  ] ++ lib.optionals withLibeuicc [
    "-DLPAC_DYNAMIC_LIBEUICC=on"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    curl
    pcsclite
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C-based eUICC Local Profile Agent (LPA)";
    homepage = "https://github.com/estkme-group/lpac";
    mainProgram = "lpac";
    license = [ licenses.agpl3Plus ] ++ optionals withLibeuicc [ licenses.lgpl21Plus ];
    maintainers = with maintainers; [ colinsane yinfeng ];
  };
})
