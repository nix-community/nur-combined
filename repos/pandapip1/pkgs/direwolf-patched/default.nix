{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  alsa-lib,
  gpsd,
  gpsdSupport ? true,
  hamlib,
  hamlibSupport ? true,
  perl,
  portaudio,
  python3,
  espeak,
  udev,
  extraScripts ? true,
}:

stdenv.mkDerivation rec {
  pname = "direwolf-pandapip1";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "wb2osz";
    repo = "direwolf";
    rev = version;
    hash = "sha256-Vbxc6a6CK+wrBfs15dtjfRa1LJDKKyHMrg8tqsF7EX4=";
  };

  patches = [
    ./pr-441.patch
    ./pr-460.patch
    # ./pr-481.patch
  ];

  postPatch =
    ''
    cp ${./direwolf_icon.ico} cmake/cpack/direwolf_icon.ico
    cp ${./direwolf_icon.png} cmake/cpack/direwolf_icon.png

      substituteInPlace src/symbols.c \
        --replace /usr/share/direwolf/symbols-new.txt $out/share/direwolf/symbols-new.txt \
        --replace /opt/local/share/direwolf/symbols-new.txt $out/share/direwolf/symbols-new.txt
      substituteInPlace src/decode_aprs.c \
        --replace /usr/share/direwolf/tocalls.txt $out/share/direwolf/tocalls.txt \
        --replace /opt/local/share/direwolf/tocalls.txt $out/share/direwolf/tocalls.txt
      substituteInPlace src/dwgpsd.c \
        --replace 'GPSD_API_MAJOR_VERSION > 11' 'GPSD_API_MAJOR_VERSION > 14'
    ''
    + lib.optionalString extraScripts ''
      patchShebangs scripts/dwespeak.sh
      substituteInPlace scripts/dwespeak.sh \
        --replace espeak ${espeak}/bin/espeak
    '';

  nativeBuildInputs = [ cmake ];

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeFeature "INSTALL_BIN_DIR" "${placeholder "out"}/bin")
    (lib.cmakeFeature "INSTALL_DOC_DIR" "${placeholder "out"}/share/doc/direwolf")
    (lib.cmakeFeature "INSTALL_MAN_DIR" "${placeholder "out"}/share/man/man1")
    (lib.cmakeFeature "INSTALL_DATA_DIR" "${placeholder "out"}/share/direwolf")
    (lib.cmakeFeature "INSTALL_UDEV_DIR" "${placeholder "out"}/etc/udev/rules.d")
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      udev
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ portaudio ]
    ++ lib.optionals gpsdSupport [ gpsd ]
    ++ lib.optionals hamlibSupport [ hamlib ]
    ++ lib.optionals extraScripts [
      python3
      perl
      espeak
    ];

  preConfigure = lib.optionals (!extraScripts) ''
    echo "" > scripts/CMakeLists.txt
  '';

  meta = {
    description = "Soundcard Packet TNC, APRS Digipeater, IGate, APRStt gateway";
    homepage = "https://github.com/wb2osz/direwolf/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ pandapip1 ];
    mainProgram = "direwolf";
  };
}
