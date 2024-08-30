{ pkgs, lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "ritual";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "rust-qt";
    repo = pname;
    rev = "51b38cab65e4dd453a7da920a3bc00da749a8931";
    hash = "sha256-3bNL7vWoGaaZtyviUkCMhhNqds4b/7HYJahhu6XZv7s=";
  };
  
  nativeBuildInputs = with pkgs; [
    pkg-config

    libclang.dev
    libclang.lib
    libsForQt5.qt5.full
  ];

  buildInputs = with pkgs; [
    openssl
    sqlite

    libclang.dev
    libclang.lib
    libsForQt5.qt5.full
  ];

  LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
  RITUAL_STD_HEADERS = "${pkgs.libcxx.dev}/include/c++/v1";
  RUST_LOG = "trace";
  RUST_BACKTRACE = "full";
  CARGO = "${pkgs.cargo}/bin/cargo";

  cargoHash = "sha256-0R4s5oNYiI2j5oJOEee1TrDpGne5geZsjp9hDh7vZ4M=";

  cargoLock = {
    lockFile = ./ritual-Cargo.lock;
    #lockFileContents = builtins.readFile ./ritual-Cargo.lock;
    outputHashes = {
      "amq-proto-0.1.0" = "sha256-0Dsx+IDucp9mnNrB+Mid5Z+BekL33MiGmDOTAjFQt0s=";
    };
  };

  buildPhase = ''
    echo  hiiiiiiiiiiiiiiiiiiiiiiiiiiii
    command -V cargo
    echo  hiiiiiiiiiiiiiiiiiiiiiiiiiiii
    echo $PATH
    echo  hiiiiiiiiiiiiiiiiiiiiiiiiiiii
    echo $CARGO
    alias cargo=${pkgs.cargo}/bin/cargo
    export PATH=${pkgs.cargo}/bin:$PATH
    ${pkgs.cargo}/bin/cargo run --bin qt_ritual -- /build/ritual-workspace -c qt_core -o main --version 5.11.3
  '';

  doCheck = false;

  # "Cargo.lock" is in the .gitignore.....
  # so we use our own Cargo.lock file for the project.
  postPatch = ''
    ln -s ${./ritual-Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "A tool, to generate rust crates from C++ Libraries";
    homepage = "https://rust-qt.github.io/ritual/";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
}
