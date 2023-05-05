{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, libX11
, glfw
, glew
, fftwFloat
, volk
  # Sources
, airspy_source ? true
, airspy
, airspyhf_source ? true
, airspyhf
, bladerf_source ? false
, libbladeRF
, file_source ? true
, hackrf_source ? true
, hackrf
, limesdr_source ? false
, limesuite
, sddc_source ? false
, rtl_sdr_source ? true
, rtl-sdr
, libusb1
, rtl_tcp_source ? true
, sdrplay_source ? false
, sdrplay
, soapy_source ? true
, soapysdr
, spyserver_source ? true
, plutosdr_source ? stdenv.isLinux
, libiio
, libad9361
  # Sinks
, audio_sink ? true
, rtaudio
, portaudio_sink ? false
, portaudio
, network_sink ? true
  # Decoders
, falcon9_decoder ? false
, m17_decoder ? false
, codec2
, meteor_demodulator ? true
, radio ? true
  # Misc
, discord_presence ? true
, frequency_manager ? true
, recorder ? true
, rigctl_server ? true
  # NUR
, zstd
, sdrpp
, weather_sat_decoder ? false
}:

sdrpp.overrideAttrs (
  old: {
    pname = "sdrpp";
    version = "2023-05-05";

    src = fetchFromGitHub {
      owner = "AlexandreRouma";
      repo = "SDRPlusPlus";
      rev = "b89fdba433cf6aa0dab424a06974a0b45abf6c4a";
      sha256 = "sha256-4sJhODH46ueb2bt8RGxVBmbTbsmZ9ARuPkZ13oaSgYY=";
    };

    buildInputs = old.buildInputs
      ++ [ zstd ];

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
  }
)
