{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, alsa-lib
, ffmpeg_4
, libvdpau
, soxr
, xvidcore
, libogg
, bzip2
, lzma
, lame
, libtheora
}:

rustPlatform.buildRustPackage rec {
  pname = "RustPlayer";
  version = "2022-12-29";

  src = fetchFromGitHub {
    rev = "a369bc19ab4a8c568c73be25c5e6117e1ee5d848";
    owner = "Kingtous";
    repo = pname;
    hash = "sha256-x82EdA7ezCzux1C85IcI2ZQ3M95sH6/k97Rv6lqc5eo=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ffmpeg-sys-next-4.4.0" = "sha256-TBgf+J+ud7nnVjf0r98/rujFPEayjEaVi+vnSE6/5Ak=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    openssl
    ffmpeg_4
    libvdpau
    libogg
    soxr
    xvidcore
    bzip2
    lzma
    lame
    libtheora
  ];

  checkFlags = [
    # network required
    "--skip=fetch_and_play"
  ];

  meta = with lib; {
    homepage = "https://github.com/Kingtous/RustPlayer";
    description = ''
      An local audio player & m3u8 radio player using
      Rust and completely terminal guimusical_note
    '';
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ oluceps ];
  };
}
