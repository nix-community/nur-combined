{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "netns-exec";
  version = "0-unstable-2016-07-30";
  src = fetchFromGitHub {
    owner = "pekman";
    repo = "netns-exec";
    rev = "aa346fd058d47b238ae1b86250f414bcab2e7927";
    fetchSubmodules = true;
    hash = "sha256-CnIgzRb58KIvdx7T9LpervSB2Ol6JMxmSM/Ti3K1+Dg=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-m4755" "-m755"

    # Force use sched func from libc
    substituteInPlace iproute2/configure \
      --replace-fail '$CC -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c' "true"

    # The bundled 2016 linux/types.h shadows the one from linux-headers and
    # lacks __u128, which glibc 2.44's asm/sigcontext.h uses on aarch64
    sed -i 's|#ifndef __ASSEMBLY__|#ifdef __SIZEOF_INT128__\ntypedef __signed__ __int128 __s128 __attribute__((aligned(16)));\ntypedef unsigned __int128 __u128 __attribute__((aligned(16)));\n#endif\n\n&|' \
      iproute2/include/linux/types.h
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/pekman/netns-exec";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = lib.licenses.gpl2Only;
    mainProgram = "netns-exec";
  };
})
