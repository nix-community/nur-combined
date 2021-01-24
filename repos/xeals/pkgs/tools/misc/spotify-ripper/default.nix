{ stdenv
, fetchFromGitHub

, python2Packages

, aacSupport ? false, faac
, alacSupport ? false, libav
, flacSupport ? false, flac
, m4aSupport ? false, mp4Support ? false, fdk-aac-encoder
, oggSupport ? false, vorbisTools
, opusSupport ? false, opusTools
}:

assert aacSupport               -> faac.meta.available;
assert alacSupport              -> libav.meta.available;
assert flacSupport              -> flac.meta.available;
assert m4aSupport || mp4Support -> fdk-aac-encoder.meta.available;
assert oggSupport               -> vorbisTools.meta.available;
assert opusSupport              -> opusTools.meta.available;

python2Packages.buildPythonApplication rec {
  pname = "spotify-ripper";
  version = "20161231.gd046419";

  src = fetchFromGitHub {
    owner = "hbashton";
    repo = pname;
    rev = "d0464193dead7bd3ac7580e98bde86a0f323acae";
    sha256 = "003d6br20f1cf4qvmpl62bk0k4h4v66ib76wn36c23bnh9x5q806";
  };

  propagatedBuildInputs = (with python2Packages; [
    colorama
    mutagen
    pyspotify
    requests
    schedule
    setuptools
  ]) ++ [
    (if flacSupport then flac else null)
    (if alacSupport then libav else null)
    (if aacSupport then faac else null)
    (if (m4aSupport || mp4Support) then fdk-aac-encoder else null)
    (if oggSupport then vorbisTools else null)
    (if opusSupport then opusTools else null)
  ];

  # Remove impure executables.
  patches = [ ./fix-setup.patch ];

  meta = {
    description = "Rip Spotify URIs to audio files, including ID3 tags and cover art";
    longDescription = ''
      Spotify-ripper is a small ripper script for Spotify that rips Spotify URIs
      to audio files and includes ID3 tags and cover art. By default
      spotify-ripper will encode to MP3 files, but includes the ability to rip
      to WAV, FLAC, Ogg Vorbis, Opus, AAC, and MP4/M4A.
    '';
    homepage = "https://github.com/hbashton/spotify-ripper";
    # spotify-ripper itself is MIT, but the upstream libspotify is unfree.
    license = stdenv.lib.licenses.unfree;
  };
}
