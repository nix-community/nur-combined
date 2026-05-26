{ lib
, stdenv
, rustPlatform
, rustc
, fetchurl
, fetchFromGitHub
, llvmPackages_20
, lld_20
, pkg-config
, cmake
, protobuf
, openssl
, glib
}:

let
  version = "2.8.0";
  rustyV8Version = "149.0.0";

  rustyV8Targets = {
    "x86_64-linux" = "x86_64-unknown-linux-gnu";
    "aarch64-linux" = "aarch64-unknown-linux-gnu";
    "aarch64-darwin" = "aarch64-apple-darwin";
  };

  rustyV8Hashes = {
    "x86_64-linux" = "sha256-0t6wy0nHj+lzwWwh1TqP5I80grBVhv1Ho5p3WvL9hmU=";
    "aarch64-linux" = "sha256-e0g5jR5kpzMyx9mjjQOBjap044mEJpxSNlYYUZA4vg8=";
    "aarch64-darwin" = "sha256-IKHRBNDkTKix851ApZTSvjSUrNX4kztgaLYQFFNrI0U=";
  };

  system = stdenv.hostPlatform.system;
  rustyV8Target = rustyV8Targets.${system}
    or (throw "deno: unsupported system ${system}");

  rustyV8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v${rustyV8Version}/librusty_v8_release_${rustyV8Target}.a.gz";
    sha256 = rustyV8Hashes.${system};
  };

  src = fetchFromGitHub {
    owner = "denoland";
    repo = "deno";
    tag = "v${version}";
    hash = "sha256-boHK278ET2uadBldr2Q8NT58RZa9xrCC4IQcoCtf3U0=";
  };
in
rustPlatform.buildRustPackage {
  pname = "deno";
  inherit version src;

  cargoHash = "sha256-1vHgkLWqwTt3tO4qSkfqwCj5KMfKCT3kscChf2FrkH8=";

  nativeBuildInputs = [
    llvmPackages_20.clang
    lld_20
    llvmPackages_20.libllvm
    pkg-config
    cmake
    protobuf
  ];

  buildInputs = [ openssl ]
    ++ lib.optionals stdenv.isLinux [ glib ];

  LIBCLANG_PATH = lib.makeLibraryPath [ llvmPackages_20.clang-unwrapped.lib ];
  RUSTY_V8_ARCHIVE = rustyV8;

  buildPhase = ''
    runHook preBuild
    unset AS
    cargo build --release --bin deno --offline
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp target/release/deno $out/bin/
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "A modern runtime for JavaScript and TypeScript";
    homepage = "https://deno.com/";
    license = lib.licenses.mit;
    mainProgram = "deno";
    platforms = lib.attrNames rustyV8Targets;
    broken = lib.versionOlder rustc.version "1.95.0";
  };
}
