{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  glib,
  e2fsprogs,
  util-linux,
  libaio,
  readline,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocfs2-tools";
  version = "1.8.9";

  src = fetchFromGitHub {
    owner = "markfasheh";
    repo = "ocfs2-tools";
    rev = "ocfs2-tools-${finalAttrs.version}";
    hash = "sha256-zSChd4QuIzVsoBu4aVXAo7kdvJJ6YecTivBjdlUK93g=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    # compile_et (com_err error-table compiler) lives in e2fsprogs' scripts output
    e2fsprogs.scripts
  ];

  buildInputs = [
    glib
    e2fsprogs
    util-linux
    libaio
    readline
    ncurses
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--with-root-prefix=${placeholder "out"}"
    "--disable-ocfs2console"
  ];

  enableParallelBuilding = true;
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  # upstream predates -Werror=format-security hardening; old code calls
  # printf-like functions with non-literal format strings
  hardeningDisable = [ "format" ];

  meta = {
    description = "Oracle Cluster File System 2 (OCFS2) userspace tools (mkfs.ocfs2, mount.ocfs2, o2cb_ctl, fsck.ocfs2, etc.)";
    homepage = "https://github.com/markfasheh/ocfs2-tools";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "mkfs.ocfs2";
  };
})
