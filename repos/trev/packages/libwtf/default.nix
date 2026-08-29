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
  version = "0-unstable-2026-08-29";

  src = fetchFromGitHub {
    owner = "andrewmd5";
    repo = "libwtf";
    rev = "343f87aa2f2120dacb4259e052ccf8f099374e0f";
    hash = "sha256-OfLIrifg5eWxq7vFd9XFmDYm8dT/txvVaIV1vQlfJZc=";
    fetchSubmodules = true;
  };

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
