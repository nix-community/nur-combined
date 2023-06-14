{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, alsa-lib
, ffmpeg
, llvmPackages_latest
}:

rustPlatform.buildRustPackage rec {
  pname = "RustPlayer";
  version = "2022-12-29";

  src = fetchFromGitHub {
    rev = "a369bc19ab4a8c568c73be25c5e6117e1ee5d848";
    owner = "Kingtous";
    repo = pname;
    sha256 = "sha256-x82EdA7ezCzux1C85IcI2ZQ3M95sH6/k97Rv6lqc5eo=";
  };
  LIBCLANG_PATH = "${llvmPackages_latest.libclang.lib}/lib";
  cargoSha256 = "sha256-MruPP/sk3JaGfrk95DhouyM698xJWSOLXPrJGKM7m58=";
  nativeBuildInputs = [ pkg-config llvmPackages_latest.clang ];
  buildInputs = [ alsa-lib openssl ffmpeg ];
  # network required
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Kingtous/RustPlayer";
    description = ''
      An local audio player & m3u8 radio player using Rust and completely terminal guimusical_note
    '';
    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ oluceps ];
  };
}
