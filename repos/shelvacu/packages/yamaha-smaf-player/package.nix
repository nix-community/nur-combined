{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "yamaha-smaf-player";
  version = "0-unstable-2026-07-03";

  src = fetchFromGitHub {
    owner = "akustikrausch";
    repo = "yamaha-smaf-player";
    rev = "627f7ad8583ce34c5fec0269ef9778167af080d6";
    hash = "sha256-wjEwNMQBKLWf4sGrHeQmDTtObSI72c0IS/2MEwRuUgU=";
  };

  patches = [ ./ma7.patch ];

  nativeBuildInputs = [ cmake ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ctest --output-on-failure
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 smaf-render "$out/bin/smaf-render"
    install -Dm644 libsmaf.a "$out/lib/libsmaf.a"
    mkdir -p "$out/include/smaf"
    install -m644 ../src/*.h "$out/include/smaf/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Yamaha SMAF ringtone renderer and FM synthesis library";
    homepage = "https://github.com/akustikrausch/yamaha-smaf-player";
    license = lib.licenses.asl20;
    mainProgram = "smaf-render";
    platforms = lib.platforms.littleEndian;
  };
}
