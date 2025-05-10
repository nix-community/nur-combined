{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  pkg-config,
  openssl,
  zstd,
}:
rustPlatform.buildRustPackage rec {
  pname = "edgee";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "edgee-cloud";
    repo = "edgee";
    tag = "v${version}";
    hash = "sha256-WhigFvy/DoM5KeXu1Rsj882jOQZr27pbO4CJ9JekN8c=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-785rYOm2/9E3qebWeRc3Q4CzGa9YgleuinMJI9qoJrI=";

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
    broken = lib.versionOlder rustc.version "1.83.0";
  };
}
