{ stdenv, lib, fetchFromGitHub, cmake, pkg-config
, libX11, glfw, glew, fftwFloat, volk, zstd
# Sources
, airspy_source ? true, airspy
, airspyhf_source ? true, airspyhf
, bladerf_source ? false, libbladeRF
, file_source ? true
, hackrf_source ? true, hackrf
, limesdr_source ? false, limesuite
, sddc_source ? false
, rtl_sdr_source ? true, rtl-sdr, libusb1
, rtl_tcp_source ? true
, sdrplay_source ? true, sdrplay
, soapy_source ? true, soapysdr
, spyserver_source ? true
, plutosdr_source ? stdenv.isLinux, libiio, libad9361
# Sinks
, audio_sink ? true, rtaudio
, portaudio_sink ? false, portaudio
, network_sink ? true
# Decoders
, falcon9_decoder ? false
, m17_decoder ? false, codec2
, meteor_demodulator ? true
, radio ? true
, weather_sat_decoder ? false
# Misc
, discord_presence ? true
, frequency_manager ? true
, recorder ? true
, rigctl_server ? true
}:

stdenv.mkDerivation rec {
  pname = "sdrpp-git";
  version = "2023-09-08";

  src = fetchFromGitHub {
    owner = "AlexandreRouma";
    repo = "SDRPlusPlus";
    rev = "a55d1d9c06122e25a5d5dab5d54c11dda30f2010";
    hash = "sha256-XANTkulYeSpqU21z+G9y9PaOYUFfRSXk8CFBUXjKpYs=";
  };

  patches = [ ./runtime-prefix.patch ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/usr/share" "share" \
      --replace "set(CMAKE_INSTALL_PREFIX" "#set(CMAKE_INSTALL_PREFIX"
    substituteInPlace decoder_modules/m17_decoder/src/m17dsp.h \
      --replace "codec2.h" "codec2/codec2.h"
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ glfw glew fftwFloat volk zstd ]
    ++ lib.optional stdenv.isLinux libX11
    ++ lib.optional airspy_source airspy
    ++ lib.optional airspyhf_source airspyhf
    ++ lib.optional bladerf_source libbladeRF
    ++ lib.optional hackrf_source hackrf
    ++ lib.optional limesdr_source limesuite
    ++ lib.optionals rtl_sdr_source [ rtl-sdr libusb1 ]
    ++ lib.optional sdrplay_source sdrplay
    ++ lib.optional soapy_source soapysdr
    ++ lib.optionals plutosdr_source [ libiio libad9361 ]
    ++ lib.optional audio_sink rtaudio
    ++ lib.optional portaudio_sink portaudio
    ++ lib.optional m17_decoder codec2;

  cmakeFlags = lib.mapAttrsToList (k: v: "-D${k}=${if v then "ON" else "OFF"}") {
    OPT_BUILD_AIRSPY_SOURCE = airspy_source;
    OPT_BUILD_AIRSPYHF_SOURCE = airspyhf_source;
    OPT_BUILD_BLADERF_SOURCE = bladerf_source;
    OPT_BUILD_FILE_SOURCE = file_source;
    OPT_BUILD_HACKRF_SOURCE = hackrf_source;
    OPT_BUILD_LIMESDR_SOURCE = limesdr_source;
    OPT_BUILD_SDDC_SOURCE = sddc_source;
    OPT_BUILD_RTL_SDR_SOURCE = rtl_sdr_source;
    OPT_BUILD_RTL_TCP_SOURCE = rtl_tcp_source;
    OPT_BUILD_SDRPLAY_SOURCE = sdrplay_source;
    OPT_BUILD_SOAPY_SOURCE = soapy_source;
    OPT_BUILD_SPYSERVER_SOURCE = spyserver_source;
    OPT_BUILD_PLUTOSDR_SOURCE = plutosdr_source;
    OPT_BUILD_AUDIO_SINK = audio_sink;
    OPT_BUILD_PORTAUDIO_SINK = portaudio_sink;
    OPT_BUILD_NETWORK_SINK = network_sink;
    OPT_BUILD_NEW_PORTAUDIO_SINK = portaudio_sink;
    OPT_BUILD_FALCON9_DECODER = falcon9_decoder;
    OPT_BUILD_M17_DECODER = m17_decoder;
    OPT_BUILD_METEOR_DEMODULATOR = meteor_demodulator;
    OPT_BUILD_RADIO = radio;
    OPT_BUILD_WEATHER_SAT_DECODER = weather_sat_decoder;
    OPT_BUILD_DISCORD_PRESENCE = discord_presence;
    OPT_BUILD_FREQUENCY_MANAGER = frequency_manager;
    OPT_BUILD_RECORDER = recorder;
    OPT_BUILD_RIGCTL_SERVER = rigctl_server;
  };

  env.NIX_CFLAGS_COMPILE = "-fpermissive";

  hardeningDisable = lib.optional stdenv.cc.isClang "format";

  meta = with lib; {
    description = "Cross-Platform SDR Software";
    homepage = "https://github.com/AlexandreRouma/SDRPlusPlus";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
