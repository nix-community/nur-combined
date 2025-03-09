{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zstd,
}:
rustPlatform.buildRustPackage rec {
  pname = "edgee";
  version = "0.8.8";

  src = fetchFromGitHub {
    owner = "edgee-cloud";
    repo = "edgee";
    tag = "v${version}";
    hash = "sha256-PLXR/z4V2qorXYorkYqRpA6kCGlYv6ZIyNqtoUY3ZHo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-u5eLJS8K0VHwua+29n4o0mlR8BqMsBgt4Y1hqeKQPS0=";

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
    changelog = "https://github.com/edgee-cloud/edgee/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "edgee";
  };
}
