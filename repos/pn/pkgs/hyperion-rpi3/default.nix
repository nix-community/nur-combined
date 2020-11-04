{ stdenv, fetchFromGitHub,
cmake, rsync,
qt48Full, xorg, libusb1, python3, libcec, zlib }:
with stdenv.lib;

let
  pname = "hyperion";
  version = "1.03.2";

  rpiFirmware = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "firmware";
    rev = "1.20190925";
    sha256 = "1b7y49rgfxffx95bkfhfr9cc95si1k6rgnbn71440grch6211w1v";
  };

  rpiTools = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "tools";
    rev = "4a335520900ce55e251ac4f420f52bf0b2ab6b1f";
    sha256 = "1b7y49rgfxffx95bkfhfr9cc95si1k6rgnbn71440grch6211w1v";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "hyperion-project";
    repo = pname;
    rev = version;
    sha256 = "02l8022g7g7sdw4ybwnb6dgkd6m0m731dzcqshngxbibsp0f9k0f";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake rsync ];
  buildInputs = [
    qt48Full
    # qt4.qtbase
    # qt4.qtsvg
    # qt4.qtserialport
    # qt4.qtx11extras
    xorg.libxcb
    xorg.libXrandr
    xorg.libXrender
    libusb1
    libcec
    python3
    zlib
  ];

  buildPhase = ''
export RASCROSS_DIR="raspberrypi"
export ROOTFS_DIR="$RASCROSS_DIR/rootfs"
export HYPERION_DIR="."
export TOOLCHAIN_FILE="$HYPERION_DIR/Toolchain-RaspberryPi.cmake"

export NATIVE_BUILD_DIR="$HYPERION_DIR/build"
export TARGET_BUILD_DIR="$HYPERION_DIR/build-rpi"

mkdir -p "$ROOTFS_DIR"

mkdir -p "$RASCROSS_DIR/firmware"
cp -r ${rpiFirmware} "$RASCROSS_DIR/firmware"
ln -s "$RASCROSS_DIR/firmware/hardfp/opt" "$ROOTFS_DIR/opt"

cp -r ${rpiTools} "$RASCROSS_DIR/tools"

mkdir -p "$NATIVE_BUILD_DIR"
cmake -DENABLE_DISPMANX=OFF --build "$NATIVE_BUILD_DIR" "$HYPERION_DIR"

# do the cross build
# specify the protoc export file to import the protobuf compiler from the native build
mkdir -p "$TARGET_BUILD_DIR"
cmake -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" -DIMPORT_PROTOC=$NATIVE_BUILD_DIR/protoc_export.cmake --build "$TARGET_BUILD_DIR" "$HYPERION_DIR"
'';

}
