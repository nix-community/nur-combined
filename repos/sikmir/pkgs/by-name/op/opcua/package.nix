{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "opcua";
  version = "0.12.0-unstable-2024-10-09";

  src = fetchFromGitHub {
    owner = "locka99";
    repo = "opcua";
    rev = "fcc89d8f8b93b5a0943ec8086706e883900faa3c";
    hash = "sha256-0rwpAVynm0EfE4Wvq37P9O/om+zjNpi7G8iETCfZX6A=";
  };

  cargoHash = "sha256-cjHr5OqDC25+4Y1qd89csHA4bjfVCPsfIQglQ3Dx/Yg=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Client and server implementation of the OPC UA specification written in Rust";
    homepage = "https://github.com/locka99/opcua";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
