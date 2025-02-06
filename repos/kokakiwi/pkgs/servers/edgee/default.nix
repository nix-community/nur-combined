{ lib

, fetchFromGitHub

, rustPlatform

, pkg-config

, openssl
, zstd
}:
rustPlatform.buildRustPackage rec {
  pname = "edgee";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "edgee-cloud";
    repo = "edgee";
    tag = "v${version}";
    hash = "sha256-8j72z/FgGA638oXIv7T0AFjFlFGvcIlRCflpEFnbuIs=";
  };

  cargoHash = "sha256-DA3StXdN4hrMLzKeKfBhG5deSdACx/ETyxDn0lD154A=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    zstd
  ];

  buildAndTestSubdir = "crates/cli";

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = {
    description = "The full-stack edge platform for your edge oriented applications";
    homepage = "https://github.com/edgee-cloud/edgee";
    license = lib.licenses.asl20;
    mainProgram = "edgee";
  };
}
