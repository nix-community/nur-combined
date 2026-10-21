{ lib
, fetchgit
, rustPlatform
, pkg-config
, cmake
, protobuf
, clang
, lld
, zstd
}:

let
  pname = "eprofiler-tui";
  version = "0.3.0";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchgit {
    url = "https://github.com/rogercoll/eprofiler-tui.git";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-T0+a62UPEaveJc8GoMnQTVegcGEYwQi2FQKbuc0IBj8=";
  };

  cargoHash = "sha256-JKnW9wqDXpFztMO+nBml6R6Z2PFvC0Y6EZZVubIvCMA=";

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
    clang
    lld
  ];

  buildInputs = [
    zstd
  ];

  env.ZSTD_SYS_USE_PKG_CONFIG = "1";

  doCheck = false;

  postInstall = ''
    install -Dm644 README.md \
      $out/share/doc/${pname}/README.md
  '';

  meta = {
    description = "eBPF profiler flamegraph based TUI";
    homepage = "https://github.com/rogercoll/eprofiler-tui";
    license = lib.licenses.asl20;
    mainProgram = "eprofiler-tui";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.linux;
  };
}
