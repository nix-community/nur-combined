{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  zlib,
  curl,
  uthash,
  git,
  ninja,
  client ? "bambu_studio",
  pluginVersion ? "02.05.00.99",
}:

let
  mosquitto-src = fetchFromGitHub {
    owner = "eclipse";
    repo = "mosquitto";
    rev = "v2.1.2";
    hash = "sha256-Zl55yjuzQY2fyaKs/zLaJ7a3OONKTDQPaT+DpPURdZI=";
  };

  cjson-src = fetchFromGitHub {
    owner = "DaveGamble";
    repo = "cJSON";
    rev = "v1.7.18";
    hash = "sha256-UgUWc/+Zie2QNijxKK5GFe4Ypk97EidG8nTiiHhn5Ys=";
  };

  miniz-src = fetchFromGitHub {
    owner = "richgel999";
    repo = "miniz";
    rev = "a4264837ae37384b1d7a205a6732db322f0f3769";
    hash = "sha256-BgPYhQAdwPx5R/BIN/Mt3bm5AaikycGClEedWFw9COk=";
  };
in
stdenv.mkDerivation {
  pname = "open-bamboo-networking-${client}";
  version = "0-unstable-2025-07-07";

  src = fetchFromGitHub {
    owner = "ClusterM";
    repo = "open-bamboo-networking";
    rev = "b6636ad34893487cc47f144a5e66d4e8b79bd027";
    hash = "sha256-u2BHI0vD9mxB0P21sCVm6goI8WczDE+/J747YDaXV7Q=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    git
  ];

  buildInputs = [
    openssl
    uthash
    zlib
    curl
  ];

  postUnpack = ''
    rm -rf "$sourceRoot/third_party/miniz"
    cp -r ${miniz-src} "$sourceRoot/third_party/miniz"
    chmod -R u+w "$sourceRoot/third_party/miniz"
  '';

  cmakeFlags = [
    (lib.cmakeFeature "OBN_VERSION" pluginVersion)
    (lib.cmakeFeature "OBN_CLIENT_TYPE" client)
    (lib.cmakeBool "OBN_PATCH_CLIENT_CONF" false)
    (lib.cmakeBool "OBN_RELEASE" true)
  ];

  preConfigure = ''
    cp -r ${mosquitto-src} $TMPDIR/mosquitto-src
    chmod -R u+w $TMPDIR/mosquitto-src
    cp -r ${cjson-src} $TMPDIR/cjson-src
    chmod -R u+w $TMPDIR/cjson-src

    cmakeFlagsArray+=(
      "-DFETCHCONTENT_SOURCE_DIR_ECLIPSE_MOSQUITTO=$TMPDIR/mosquitto-src"
      "-DFETCHCONTENT_SOURCE_DIR_CJSON=$TMPDIR/cjson-src"
    )
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    find . -maxdepth 2 \( -name "libbambu_networking.so" -o -name "libBambuSource.so" \) \
      -exec cp {} $out/lib/ \;
    runHook postInstall
  '';

  meta = {
    description = "Open-source drop-in replacement for Bambu Studio's proprietary bambu_networking plugin";
    homepage = "https://github.com/ClusterM/open-bamboo-networking";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
