{
  cmake,
  fetchFromGitHub,
  git,
  lib,
  nix-update-script,
  openssl,
  pkg-config,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwtf";
  version = "0-unstable-2026-11-23";

  src = fetchFromGitHub {
    owner = "andrewmd5";
    repo = "libwtf";
    rev = "a0787aab054f17f8c6988abcddb6c94ee49da73a";
    hash = "sha256-JI9bmPnkMblJ8c6suHDBgfPFAvAJ/en8eZpAtfcpyw8=";
    fetchSubmodules = true;
  };

  # glibc 2.44 declares C23 once_flag/call_once in stdlib.h, which collides with
  # tinycthread's macros unless stdlib.h is included before they are defined
  postPatch = ''
    substituteInPlace deps/tinycthreads/tinycthread.h \
      --replace-fail "#include <pthread.h>" $'#include <pthread.h>\n#include <stdlib.h>'
  '';

  nativeBuildInputs = [
    cmake
    git
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cmakeFlags = [
    (lib.cmakeBool "QUIC_USE_EXTERNAL_OPENSSL" true)
    (lib.cmakeBool "WTF_BUILD_SAMPLES" false)
    (lib.cmakeBool "WTF_BUILD_TESTS" false)
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      "--version=branch=main"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "C WebTransport over HTTP/3 library built on MsQuic";
    homepage = "https://github.com/andrewmd5/libwtf";
    changelog = "https://github.com/andrewmd5/libwtf/commits/main";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
