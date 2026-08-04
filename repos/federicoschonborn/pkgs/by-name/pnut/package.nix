{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2025-07-01";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "4067ed78c2fb81a3f1a903ad40d82946716831ec";
    hash = "sha256-LbnmJZrXO3CS6DoPWQN0JfzoPu9uMq/aJ6iid/K5zbE=";
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
