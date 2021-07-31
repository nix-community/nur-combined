{ stdenv, lib, fetchFromGitHub, cmake, pkg-config
, libX11, glfw, glew, fftwFloat, volk
# Sources
, airspy_source ? false, airspy
, airspyhf_source ? true, airspyhf
, bladerf_source ? true, libbladeRF
, file_source ? true
, hackrf_source ? true, hackrf
, limesdr_source ? true, limesuite
, sddc_source ? false
, rtl_sdr_source ? true, librtlsdr, libusb
, rtl_tcp_source ? true
, sdrplay_source ? false, sdrplay
, soapy_source ? true, soapysdr
, spyserver_source ? false
, plutosdr_source ? true, libiio, libad9361
# Sinks
, audio_sink ? true, rtaudio
# Decoders
, falcon9_decoder ? false, ffmpeg-full
, meteor_demodulator ? true
, radio ? true
, weather_sat_decoder ? false
# Misc
, discord_integration ? true
, frequency_manager ? true
, recorder ? true
}:

stdenv.mkDerivation rec {
  pname = "sdrpp";
  version = "2021-07-31";

  src = fetchFromGitHub {
    owner = "AlexandreRouma";
    repo = "SDRPlusPlus";
    rev = "99096885f54bd056c3e461c8319f71304d5e6e39";
    hash = "sha256-pCRf/Kk3kJ6M1FkoYthQHZaRm8OZKjJu2bg3g/qQC6o=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/usr" $out
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ glfw glew fftwFloat volk ]
    ++ lib.optional stdenv.isLinux libX11
    ++ lib.optional airspy_source airspy
    ++ lib.optional airspyhf_source airspyhf
    ++ lib.optional bladerf_source libbladeRF
    ++ lib.optional hackrf_source hackrf
    ++ lib.optional limesdr_source limesuite
    ++ lib.optionals rtl_sdr_source [ librtlsdr libusb ]
    ++ lib.optional sdrplay_source sdrplay
    ++ lib.optional soapy_source soapysdr
    ++ lib.optionals plutosdr_source [ libiio libad9361 ]
    ++ lib.optional audio_sink rtaudio;

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
    OPT_BUILD_FALCON9_DECODER = falcon9_decoder;
    OPT_BUILD_METEOR_DEMODULATOR = meteor_demodulator;
    OPT_BUILD_RADIO = radio;
    OPT_BUILD_WEATHER_SAT_DECODER = weather_sat_decoder;
    OPT_BUILD_DISCORD_PRESENCE = discord_integration;
    OPT_BUILD_FREQUENCY_MANAGER = frequency_manager;
    OPT_BUILD_RECORDER = recorder;
  };

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Cross-Platform SDR Software";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
