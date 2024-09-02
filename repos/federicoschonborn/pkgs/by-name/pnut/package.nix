{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "pnut";
  version = "0-unstable-2024-08-31";

  src = fetchFromGitHub {
    owner = "udem-dlteam";
    repo = "pnut";
    rev = "e01e3895b64d39c4b93d2639261b4c2d4750cef3";
    hash = "sha256-wEj+ASXyrxn1pIyMj2tvizqW4SoFFqRMjgJ2VmtunwA=";
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
