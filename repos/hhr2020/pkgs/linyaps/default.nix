{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  copyDesktopItems,
  pkg-config,
  wrapQtAppsNoGuiHook,

  cli11,
  curl,
  gpgme,
  gtest,
  libarchive,
  libelf,
  libsodium,
  libsysprof-capture,
  nlohmann_json,
  openssl,
  ostree,
  qtbase,
  systemdLibs,
  tl-expected,
  uncrustify,
  xz,
  yaml-cpp,

  replaceVars,
  linyaps-box,
  bash,
  binutils,
  coreutils,
  desktop-file-utils,
  erofs-utils,
  fuse3,
  fuse-overlayfs,
  gnutar,
  glib,
  shared-mime-info,
}:

let
  erofs-utils' = erofs-utils.override {
    fuse = fuse3;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "linyaps";
  version = "1.9.8";

  src = fetchFromGitHub {
    owner = "OpenAtom-Linyaps";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-GOgjL6I33HA4BYBc/oXwXPgEk0w360eM+BSKddpwAxg=";
  };

  patches = [
    ./fix-path.patch
    ./disable-static-link.patch
    (replaceVars ./patch-binary-path.patch {
      bash = lib.getExe bash;
      cp = lib.getExe' coreutils "cp";
      sh = lib.getExe' bash "sh";
      mkfs_erofs = lib.getExe' erofs-utils' "mkfs.erofs";
      erofsfuse = lib.getExe' erofs-utils' "erofsfuse";
      fusermount = lib.getExe' fuse3 "fusermount3";
      tar = lib.getExe gnutar;
      objcopy = lib.getExe' binutils "objcopy";
      ar = lib.getExe' binutils "ar";
      update-desktop-database = lib.getExe' desktop-file-utils "update-desktop-database";
      update-mime-database = lib.getExe' shared-mime-info "update-mime-database";
      glib-compile-schemas = lib.getExe' glib "glib-compile-schemas";
      fuse-overlayfs = lib.getExe fuse-overlayfs;
    })
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LINGLONG_DEFAULT_OCI_RUNTIME" (lib.getExe linyaps-box))
  ];

  # postPatch = ''
  #   substituteInPlace apps/dumb-init/CMakeLists.txt \
  #     --replace-fail "target_link_options(\''${DUMB_INIT_TARGET} PRIVATE -static)" \
  #                    "target_link_options(\''${DUMB_INIT_TARGET} PRIVATE -static -L${stdenv.cc.libc.static}/lib -lc -lm)"
  #   cat apps/dumb-init/CMakeLists.txt
  # '';

  buildInputs = [
    cli11
    curl
    gpgme
    gtest
    libarchive
    libelf
    libsodium
    libsysprof-capture
    nlohmann_json
    openssl
    ostree
    qtbase
    systemdLibs
    tl-expected
    uncrustify
    xz
    yaml-cpp
  ];

  nativeBuildInputs = [
    cmake
    copyDesktopItems
    pkg-config
    wrapQtAppsNoGuiHook
  ];

  meta = {
    description = "Cross-distribution package manager with sandboxed apps and shared runtime";
    homepage = "https://linyaps.org.cn/";
    downloadPage = "https://github.com/OpenAtom-Linyaps/linyaps";
    changelog = "https://github.com/OpenAtom-Linyaps/linyaps/releases/tag/${finalAttrs.version}";
    mainProgram = "ll-cli";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
  };
})
