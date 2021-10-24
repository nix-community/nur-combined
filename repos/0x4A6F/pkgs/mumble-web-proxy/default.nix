{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, libnice
, glibc
, llvmPackages
}:

rustPlatform.buildRustPackage rec {
  pname = "mumble-web-proxy";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "johni0702";
    repo = "mumble-web-proxy";
    rev = "cfae6178c70c1436186f16723b18a2cbb0f06138";
    sha256 = "0l194xida852088l8gv7v2ygjxif46fhzp18dvv19i7wssgq8jkf";
  };

  # building fails due to rtp -> https://github.com/Johni0702/mumble-web-proxy/issues/22
  cargoPatches = [
    ./Cargo.lock.patch
    ./Cargo.toml.patch
  ];
  cargoSha256 = "0lk2war7507d7l8ixin78yl89ccgrz4rag7461pas8v8cvk7q8ra";

  nativeBuildInputs = with llvmPackages; [
    pkg-config
    llvm
    clang
  ];
  buildInputs = [
    openssl
    libnice
    glibc
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  meta = with lib; {
    description = "Mumble to WebSocket+WebRTC proxy for use with mumble-web";
    homepage = "https://github.com/johni0702/mumble-web-proxy";
    license = licenses.unfree;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
