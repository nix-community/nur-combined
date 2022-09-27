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
  version = "d37026dcc3c0b77e527b8e3e814de7e5be894d46";

  src = fetchFromGitHub {
    rev = "${version}";
    owner = "Kingtous";
    repo = pname;
    sha256 = "sha256-lmVdqc9SlDndMDlgY8ULRSUdQRV1mW5p2uz14eShF+k=";
  };
  LIBCLANG_PATH = "${llvmPackages_latest.libclang.lib}/lib";
  cargoSha256 = "sha256-4CplfS8JVLKzsJjT/FdQLa4WXhB2Z2yYz855xDXrMNs=";
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
