{
  lib,
  clangStdenv,
  fetchFromGitLab,
  bionic-translation,
  python3,
  which,
  jdk17,
  zip,
  xz,
  icu,
  zlib,
  libcap,
  expat,
  openssl,
  libbsd,
  lz4,
  runtimeShell,
  libpng,
  makeWrapper,
  binutils,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "art-standalone";
  version = "0-unstable-2026-10-18";

  src = fetchFromGitLab {
    owner = "android_translation_layer";
    repo = "art_standalone";
    rev = "a1edfc40e8cea3644d80e4e776d3fa7fc397a1c2";
    hash = "sha256-2ct0OrwXDXF3/fvg5mdOmpqdf2/NvoBdwpFIm1IxoRg=";
  };

  patches = [
    # Do not hardocde addr2line binary path
    ./no-hardcode-path-addr2line.patch
    ./remove-wolfssljni.patch
    ./fake_log_device.patch
    ./runtime_offsetof.patch
    ./writer.patch
    ./backtrace.patch
    ./dex2oat.patch
    ./check_jni.patch
    ./jni_internal.patch
    ./agent.patch
    ./parsed_options.patch
    ./runtime_dladdr.patch
  ];

  postPatch = ''
    chmod +x dalvik/dx/etc/{dx,dexmerger}
    patchShebangs .
    substituteInPlace build/core/config.mk build/core/main.mk \
      --replace-fail "/bin/bash" "${runtimeShell}"
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  enableParallelBuilding = true;

  strictDeps = true;

  nativeBuildInputs = [
    jdk17
    makeWrapper
    python3
    which
    zip
  ];

  buildInputs = [
    bionic-translation
    expat
    icu
    libbsd
    libcap
    libpng
    lz4
    openssl
    xz
    zlib
  ];

  makeFlags = [
    "____LIBDIR=lib"
    "____PREFIX=${placeholder "out"}"
    "____INSTALL_ETC=${placeholder "out"}/etc"
    "CC=clang"
    "CXX=clang++"
    "HOST_CC=clang"
    "HOST_CXX=clang++"
  ];

  postFixup = ''
    wrapProgram $out/bin/dx \
      --prefix LD_LIBRARY_PATH : $out/lib \
      --prefix PATH : ${lib.makeBinPath [ binutils ]}
  '';

  meta = {
    description = "Art and dependencies with modifications to make it work on Linux";
    homepage = "https://gitlab.com/android_translation_layer/art_standalone";
    # No license specified yet
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ onny ];
  };
})
