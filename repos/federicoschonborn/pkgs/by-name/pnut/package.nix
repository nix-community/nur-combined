{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2025-06-24";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "5f9c64e1bdeacac264f8a5bbe96795c8ecbcf955";
    hash = "sha256-jM8J70NKdh9JVDzTN0Cb101ez49E+IGKdbQLJbEVfRs=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "gcc" "cc" \
      --replace-fail "sudo cp" "cp" \
      --replace-fail "/usr/local" "$out"
  '';

  preInstall = ''
    mkdir -p $out/bin
  '';

  makeFlags = [
    "pnut-sh"
    "pnut-sh.sh"
  ];

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    mainProgram = "pnut";
    description = "A Self-Compiling C Transpiler Targeting Human-Readable POSIX Shell";
    homepage = "https://github.com/udem-dlteam/pnut";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
