{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2024-09-05";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "c73549e29cb9b54fffe186d62cec6ef31ddef26e";
    hash = "sha256-goGsmdhhIv5hbZYsrO8aTNHk9gPWobHl0kyuZnNb7SE=";
  };

  makeFlags = [
    "pnut-sh"
    "pnut.sh"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ls build
    cp build/pnut-sh $out/bin/pnut
    cp build/pnut.sh $out/bin/pnut.sh

    runHook postInstall
  '';

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
