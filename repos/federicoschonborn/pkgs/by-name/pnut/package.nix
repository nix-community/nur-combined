{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "SLE2024-artifact-unstable-2025-01-08";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "93bbc5c7212e7f64832f0216807703f24d9a9483";
    hash = "sha256-HcuXHlO/0eso9YXJRI7A0SmcB/GoM/W/2GzZw0ykhDo=";
  };

  makeFlags = [
    "pnut-sh"
    "pnut-sh.sh"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ls build
    cp build/pnut-sh $out/bin/pnut
    cp build/pnut-sh.sh $out/bin/pnut.sh

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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
