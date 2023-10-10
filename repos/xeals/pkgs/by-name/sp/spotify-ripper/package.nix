{ lib
, fetchFromGitHub

, python3Packages
, lame

, aacSupport ? false
, faac
, alacSupport ? false
, libav
, flacSupport ? false
, flac
, m4aSupport ? false
, mp4Support ? false
, fdk-aac-encoder
, oggSupport ? false
, vorbis-tools
, opusSupport ? false
, opusTools
}:

assert aacSupport -> faac.meta.available;
assert alacSupport -> libav.meta.available;
assert flacSupport -> flac.meta.available;
assert m4aSupport || mp4Support -> fdk-aac-encoder.meta.available;
assert oggSupport -> vorbis-tools.meta.available;
assert opusSupport -> opusTools.meta.available;

python3Packages.buildPythonApplication rec {
  pname = "spotify-ripper";
  version = "20210724.5bfd3f7";

  src = fetchFromGitHub {
    owner = "ast261";
    repo = pname;
    rev = "5bfd3f7a52f2767b433fd315145409837a3c33f0";
    sha256 = "sha256-LLunGzs9Mg4S00Su260b+M5w/XwS+kICl/YXQdR/cPI=";
  };

  propagatedBuildInputs = (with python3Packages; [
    colorama
    mutagen
    pyspotify
    requests
    schedule
    setuptools
    spotipy
  ]) ++ [
    lame
    (if flacSupport then flac else null)
    (if alacSupport then libav else null)
    (if aacSupport then faac else null)
    (if (m4aSupport || mp4Support) then fdk-aac-encoder else null)
    (if oggSupport then vorbis-tools else null)
    (if opusSupport then opusTools else null)
  ];

  # Remove impure executables.
  patches = [ ./fix-setup.patch ];

  meta = with lib; {
    description = "Rip Spotify URIs to audio files, including ID3 tags and cover art";
    longDescription = ''
      Spotify-ripper is a small ripper script for Spotify that rips Spotify URIs
      to audio files and includes ID3 tags and cover art. By default
      spotify-ripper will encode to MP3 files, but includes the ability to rip
      to WAV, FLAC, Ogg Vorbis, Opus, AAC, and MP4/M4A.
    '';
    homepage = "https://github.com/hbashton/spotify-ripper";
    # spotify-ripper itself is MIT, but the upstream libspotify is unfree.
    license = licenses.unfree;
  };
}
