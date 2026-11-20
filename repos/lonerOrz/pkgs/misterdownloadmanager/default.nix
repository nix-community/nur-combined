{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  llvmPackages,
  nasm,
  python3,
  openssl,
  aws-lc,
  zlib,
  dbus,
  libxkbcommon,
  wayland,
  libGL,
  makeWrapper,
  yt-dlp,
  ffmpeg,
  gallery-dl,
  p7zip,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "misterdownloadmanager";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "anefzaoui";
    repo = "misterdownloadmanager";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WRBG1npj6+//0YjWooMmw03ngVRkDx1WyhvwOL2+7sc=";
  };

  cargoHash = "sha256-+l1+VATWsXyAD/JRq8tIfED7lIRsfJK95bWhVR6NSGE=";

  nativeBuildInputs = [
    pkg-config
    cmake
    llvmPackages.clang
    llvmPackages.llvm
    nasm
    python3
    makeWrapper
  ];

  buildInputs = [
    openssl
    aws-lc
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    libxkbcommon
    wayland
    libGL
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    for bin in $out/bin/*; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            libxkbcommon
            wayland
            libGL
          ]
        } \
        --prefix PATH : ${
          lib.makeBinPath [
            yt-dlp
            ffmpeg
            gallery-dl
            p7zip
          ]
        }
    done
  '';

  # 上游测试依赖本地 labserver / 网络，沙箱内不稳定
  doCheck = false;

  meta = {
    description = "The ultimate open-source, clean-room download manager written from scratch in pure Rust";
    homepage = "https://github.com/anefzaoui/misterdownloadmanager";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "mdm-app";
  };
})
