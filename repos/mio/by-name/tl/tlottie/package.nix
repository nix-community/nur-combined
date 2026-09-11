{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "tlottie";
  version = "0.1.0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "dkaraush";
    repo = "tlottie";
    rev = "00e111bc2edb1b9b378cee3cbb4ade1094a1280a";
    hash = "sha256-XjjGiTdu736z/5uWG12Rnom2LszzE3GClk9p+q0Hchs=";
  };

  cargoHash = "sha256-R/l5zMRB/2/a4Yf6toPBBvJ1SvebWsGeumwW9U6b7So=";

  # forkgram/tdesktop imports this as a native library + C header.
  buildNoDefaultFeatures = true;
  buildFeatures = [
    "c-api"
    "cpu"
    "std"
  ];

  cargoBuildFlags = [ "--lib" ];

  postPatch = ''
    sed -i 's/crate-type = \["rlib", "cdylib"\]/crate-type = ["rlib", "cdylib", "staticlib"]/' Cargo.toml
  '';

  doCheck = false;

  postInstall = ''
    mkdir -p "$out/include/tlottie" "$out/lib"
    install -Dm644 include/tlottie.h "$out/include/tlottie/tlottie.h"

    shopt -s nullglob
    found=
    for f in \
      target/${stdenv.hostPlatform.rust.rustcTarget}/release/libtlottie.so \
      target/release/libtlottie.so \
      target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/libtlottie.so; do
      install -Dm755 "$f" "$out/lib/libtlottie.so"
      found=1
      break
    done
    for f in \
      target/${stdenv.hostPlatform.rust.rustcTarget}/release/libtlottie.a \
      target/release/libtlottie.a \
      target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/libtlottie.a; do
      install -Dm644 "$f" "$out/lib/libtlottie.a"
      found=1
      break
    done
    shopt -u nullglob

    if [ -z "$found" ]; then
      echo "tlottie: failed to find libtlottie.{so,a} under target/" >&2
      find target -name 'libtlottie*' -print >&2 || true
      exit 1
    fi
  '';

  meta = {
    description = "Fast Lottie renderer with a C API (used by Forkgram/Telegram Desktop)";
    homepage = "https://github.com/dkaraush/tlottie";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
