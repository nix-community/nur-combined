{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2024-08-09";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "390f3ad2031fb389c743df854fe81de83385d61f";
    hash = "sha256-WypvE+/K6PeOkIuyq/4Swe2yjLYHBO73nVc/wk+Nm5E=";
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
