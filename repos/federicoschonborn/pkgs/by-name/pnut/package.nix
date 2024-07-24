{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2024-07-24";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "a219e63acd6a2823cfa35a16d6ef6a2220616e77";
    hash = "sha256-EEYq49vLXLXDz+HcVzVjs/SIk52webPsayQhnkNXvsM=";
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

  meta = {
    mainProgram = "pnut";
    description = "A Self-Compiling C Transpiler Targeting Human-Readable POSIX Shell";
    homepage = "https://github.com/udem-dlteam/pnut";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
