{ rustPlatform
, fetchFromGitHub
, rust-cbindgen
}:
rustPlatform.buildRustPackage rec {
  pname = "signal-fts5-extension";
  # via Alpine package:
  # > follow @signalapp/better-sqlite3 (on version in package.json) -> deps/download.js -> TOKENIZER_VERSION
  # > last bsqlite version: 8.5.2
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-FTS5-Extension";
    rev = "v${version}";
    hash = "sha256-MzgdRuRsfL3yhlVU0RAAUtAaOukMpqSSa42nRYhpmh0=";
  };

  cargoHash = "sha256-ZTrqkMBqSsGs80oWIrD6hBKMnjo2Da4d5FumnUNdves=";

  nativeBuildInputs = [
    rust-cbindgen
  ];

  postBuild = ''
    cbindgen --profile release . -o $out/include/signal-tokenizer.h
  '';

  # stokenizerver = "0.2.1";
  # stokenizer = fetchurl {
  #   url = "https://github.com/signalapp/Signal-FTS5-Extension/archive/refs/tags/v${stokenizerver}/stokenizer-${stokenizerver}.tar.gz";
  #   hash = "sha256-Kl2gZAtxIw4FZWrga4V6c9TMGCirQ9CEzhRz2laSAE0=";
  # };
}
