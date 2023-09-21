{ stdenv
, lib
, fetchFromGitHub
, python3
, ffmpeg
}:

stdenv.mkDerivation rec {
  pname = "ytarchive";
  version = "0.2.2+0304577";

  src = fetchFromGitHub {
    owner = "Kethsar";
    repo = "ytarchive";
    # NOTE: Last revision where it was written in Python, so don't change
    #   without rewriting the derivation.
    rev = "030457749d6c8d1d62240bfbad659326f3cd3a30";
    hash = "sha256-mvmdkxZxlEbWc7GR8LfyxTJOeEhjCoYyeatDx8l1uhM=";
  };

  propagatedBuildInputs = [
    python3
    ffmpeg
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    install -Dm00755 ytarchive.py $out/bin/ytarchive
  '';

  meta = with lib; {
    description = "Garbage Youtube livestream downloader";
    homepage = "https://github.com/Kethsar/ytarchive";
    license = licenses.mit;
    platforms = python3.meta.platforms;
  };
}
