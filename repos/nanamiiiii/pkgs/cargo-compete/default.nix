{
  fetchFromGitHub,
  lib,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-compete";
  version = "0.10.7";

  src = fetchFromGitHub {
    owner = "qryxip";
    repo = "cargo-compete";
    tag = "v${version}";
    hash = "sha256-qlRVHSUVOqdTx4H3pE19Fy634742veTisHm6IqfKBUQ=";
  };

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  cargoHash = "sha256-lid1tyR8Y6lvjpeGJ4vGzqDTY6V2y/5rL9fGyjyF3yw=";
  doCheck = false; # this requires network access

  meta = {
    description = "Cargo subcommand for competitive programming";
    longDescription = ''
      A Cargo subcommand for competitive programming.
      Supports AtCoder, Codeforces, and yukicoder. Other websites are available via online-judge-tools/api-client.
    '';
    homepage = "https://github.com/qryxip/cargo-compete";
    changelog = "https://github.com/qryxip/cargo-compete/blob/master/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "cargo-compete";
  };
}
