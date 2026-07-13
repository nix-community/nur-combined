{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  apple-sdk,
}:

rustPlatform.buildRustPackage rec {
  pname = "probe";
  version = "0.6.0-rc327";

  src = fetchFromGitHub {
    owner = "buger";
    repo = "probe";
    rev = "v${version}";
    hash = "sha256-dQMnmAR84O67YPAJEMimQC6ObnJFlLPfBmAJmz9tAtI=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tree-sitter-crystal-0.0.1" = "sha256-f0/i9JHYWeif9xeZPKNacEnwcp6mPRRfFZ90I3lRgW8=";
      "turso-0.3.0-pre.3" = "sha256-jiPoNgwgKWvLVyWzR9GAgeuMsEZ6Xwm9xV7gLhBU01c=";
    };
  };

  postPatch = ''
    ln -s ${cargoLock.lockFile} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      apple-sdk
    ];

  doCheck = false;

  meta = {
    description = "Probe is an AI-friendly, fully local, semantic code search engine which which works with for large codebases. The final missing building block for next generation of AI coding tools";
    homepage = "https://github.com/buger/probe";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "probe";
  };
}
