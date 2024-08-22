{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2024-08-19";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "d426936f7d21644522fbd972b1f80fdd5f102f8e";
    hash = "sha256-uFhNa91GNfmi9/Y1U+vUIVNM0/K7xzKDE3EnRTHqF6o=";
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
    badPlatforms = with lib.platforms; i686 ++ darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
