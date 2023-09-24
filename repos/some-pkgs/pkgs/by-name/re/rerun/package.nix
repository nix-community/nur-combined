{ lib
, arrow-cpp
, stdenv
, cargo
, catch2_3
, cmake
, fetchFromGitHub
, libxkbcommon
, loguru
, pkg-config
, protobuf
, rustc
, rustPlatform
, vulkan-loader
, zstd
, darwin
, wayland
}:

stdenv.mkDerivation rec {
  pname = "rerun";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "rerun-io";
    repo = "rerun";
    rev = version;
    hash = "sha256-KSXA3NzxeRZ1NXqJvqpSzRLLpYT+xB5QdJRZFetmRC8=";
  };
  postPatch = ''
    sed -i \
      -e '/GIT_TAG/a FIND_PACKAGE_ARGS REQUIRED NAMES loguru COMPONENTS loguru' \
      -e 's/cmake_minimum_required.*$/cmake_minimum_required(VERSION 3.24)/' \
      rerun_cpp/CMakeLists.txt
  '';

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    cargo
    cmake
    pkg-config
    protobuf
    rustPlatform.cargoSetupHook
    rustc
  ];

  buildInputs = [
    arrow-cpp
    catch2_3
    loguru
    libxkbcommon
    vulkan-loader
    zstd
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.IOKit
    darwin.apple_sdk.frameworks.Metal
    darwin.apple_sdk.frameworks.QuartzCore
    darwin.apple_sdk.frameworks.Security
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  meta = with lib; {
    broken = true;
    description = "Log images, point clouds, etc, and visualize them effortlessly. Built in Rust using egui";
    homepage = "https://github.com/rerun-io/rerun";
    changelog = "https://github.com/rerun-io/rerun/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ ];
    mainProgram = "rerun";
    platforms = platforms.all;
  };
}
