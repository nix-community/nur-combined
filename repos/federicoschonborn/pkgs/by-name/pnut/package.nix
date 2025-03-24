{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "SLE2024-artifact-unstable-2025-03-21";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "3d7a38579307e670a713197b1b1ba2961c84903d";
    hash = "sha256-l6chUB8uf9X7Ks/3XsaZtIX9xOZhLtlvtBzHWJU9shM=";
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
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
