{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, alsa-lib
, ffmpeg
, llvmPackages_latest
, libclang
, libllvm
}:

rustPlatform.buildRustPackage rec {
  pname = "RustPlayer";
  version = "772774ac03be3b45c2bc60e0d32eea1ff68c2dd9";

  src = fetchFromGitHub {
    rev = "${version}";
    owner = "Kingtous";
    repo = pname;
    sha256 = "sha256-iaXaT5O6zDVBdCKeNQ+p/Gk6gXbTOus9com70HRfJXU=";
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
