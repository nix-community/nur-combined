#!/usr/bin/env bash

set -eux

PACK_DIR="$NIX_BUILD_TOP/.pack"
PREFIX_PATH="$PACK_DIR/install/idris2"
BOOT_PATH="$PACK_DIR/install/idris2/bin/idris2"

# Bootstrap the Idris compiler
pushd "$NIX_BUILD_TOP/Idris2"
make bootstrap PREFIX="$PREFIX_PATH" SCHEME="$SCHEME"

# Install Idris2
make install PREFIX="$PREFIX_PATH" IDRIS2_CG="$CG"
make clean
make all IDRIS2_BOOT="$BOOT_PATH" PREFIX="$PREFIX_PATH" IDRIS2_CG="$CG"
make install IDRIS2_BOOT="$BOOT_PATH" PREFIX="$PREFIX_PATH" IDRIS2_CG="$CG"
make install-with-src-libs IDRIS2_BOOT="$BOOT_PATH" PREFIX="$PREFIX_PATH" IDRIS2_CG="$CG"
make install-with-src-api IDRIS2_BOOT="$BOOT_PATH" PREFIX="$PREFIX_PATH" IDRIS2_CG="$CG"
popd

# Install filepath
pushd "$NIX_BUILD_TOP/idris2-filepath"
"$BOOT_PATH" --install filepath.ipkg
popd

# # Install toml-idr
pushd "$NIX_BUILD_TOP/toml-idr"
"$BOOT_PATH" --install toml.ipkg
popd

# Install pack
pushd "$NIX_BUILD_TOP/idris2-pack"
"$BOOT_PATH" --build pack.ipkg
popd
