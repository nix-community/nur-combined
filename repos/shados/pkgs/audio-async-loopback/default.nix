{
  lib,
  stdenv,
  pins,
  libsamplerate,
  pulseaudio,
  ffmpeg_6,
}:

stdenv.mkDerivation rec {
  pname = "audio-async-loopback";
  version = "unstable-2023-07-03";

  src = pins.audio-async-loopback.outPath;

  buildInputs = [
    libsamplerate
    pulseaudio
    ffmpeg_6
  ];

  buildPhase = ''
    gcc ''${CFLAGS} -o audio_async_loopback main.c iec_61937.c pcm_sink.c ac3_sink.c -lpulse-simple -lsamplerate -lpthread -lavutil -lavcodec -Wall -O3 -flto
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/{licenses,doc}/audio-async-loopback

    install -Dm755 audio_async_loopback $out/bin/audio-async-loopback
    install -Dm644 LICENSE $out/share/licenses/audio-async-loopback/
    install -Dm644 README.md $out/share/doc/audio-async-loopback/
  '';

  meta = with lib; {
    description = "Real-time S/PDIF PCM/AC3 capture and playback";
    homepage = "https://github.com/jakemoroni/audio_async_loopback";
    maintainers = with maintainers; [ arobyn ];
    license = licenses.gpl3;
  };
}
