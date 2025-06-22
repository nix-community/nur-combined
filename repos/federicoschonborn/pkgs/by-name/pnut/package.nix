{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2025-06-19";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "50a5954c6214cbd52a6b6c171f846b6494dc6a77";
    hash = "sha256-gPROsqsZdC7Tqzn43f5wWOv8TsldeCe3hH50HgexF7Q=";
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
