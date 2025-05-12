{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "SLE2024-artifact-unstable-2025-05-04";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "1632f1b6ace52170f956e36e0c1e9870c8c21d08";
    hash = "sha256-1GOSNlncOHqxK1GDEOppQ7LQUaffr+us+32vTpyF3v8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "pnut";
    description = "A Self-Compiling C Transpiler Targeting Human-Readable POSIX Shell";
    homepage = "https://github.com/udem-dlteam/pnut";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
