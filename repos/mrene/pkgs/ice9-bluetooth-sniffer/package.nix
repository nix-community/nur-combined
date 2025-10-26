{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, cmake
, pkg-config
, liquid-dsp
, hackrf
, libbladeRF
, uhd
, fftwFloat
, unixtools
, darwin ? null
, lld ? null
}:

stdenv.mkDerivation {
  pname = "ice9-bluetooth-sniffer";
  version = "23.06.0";

  src = fetchFromGitHub {
    owner = "mikeryan";
    repo = "ice9-bluetooth-sniffer";
    rev = "2d504c7b50db2d7d0dcb41cff61f798b59b9b5c5";
    hash = "sha256-o2Ri5WAqGoi1Ck5cjP8VRwtYSHPQo0aONufrF/V3f6c=";
  };

  patches = [
    ./usrp-fixes.patch
  ];

  cmakeFlags = lib.optional stdenv.isDarwin (lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" "-fuse-ld=lld");

  # On Darwin platforms:
  # error: call to undeclared function '_NSGetExecutablePath'; ISO C99 and later do not support implicit function declarations [-Wimplicit-function-declaration]
  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-Wno-implicit-function-declaration";

  nativeBuildInputs = [ cmake pkg-config unixtools.xxd ] ++ 
    lib.optionals stdenv.isDarwin [ lld ];

  buildInputs = [
    liquid-dsp
    libbladeRF
    hackrf
    uhd
    fftwFloat
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.IOSurface
    darwin.apple_sdk.frameworks.QuartzCore
  ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    install_name_tool -change libliquid.dylib ${liquid-dsp}/lib/libliquid.dylib $out/bin/ice9-bluetooth
  '';

  meta = with lib; {
    description = "Wireshark-compatible all-channel BLE sniffer for bladeRF, with wideband Bluetooth sniffing for HackRF and USRP";
    homepage = "https://github.com/mikeryan/ice9-bluetooth-sniffer";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "ice9-bluetooth";
    platforms = platforms.unix;
  };
}
