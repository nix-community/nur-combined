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
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "edgee-cloud";
    repo = "edgee";
    tag = "v${version}";
    hash = "sha256-brbSzZYCt7KmAJqX9eGSgya0M1Pz+xNlb0z9Et/dTvU=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Af4qubtQ1uPLI/aogGLDJNY4IPevLaRFBA1d7DZJtV8=";

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
