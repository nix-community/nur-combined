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
  version = "0.8.7";

  src = fetchFromGitHub {
    owner = "edgee-cloud";
    repo = "edgee";
    tag = "v${version}";
    hash = "sha256-j6hB+X38qgTrUe6DHkmfOpYTnXda+aHZQPj/E1mNYZE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-tyTUoq1UfZ/IitaBBMGE7BBLZd7P/HSecMPMy4FlhYI=";

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
