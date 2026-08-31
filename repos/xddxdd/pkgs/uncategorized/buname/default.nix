{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  makeWrapper,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "buname";
  version = "0-unstable-2025-09-18";
  src = fetchFromGitHub {
    owner = "dramforever";
    repo = "buname";
    rev = "a62d3d214dafb92932f4e5478eebc212ae4cb57d";
    hash = "sha256-5pzAhggb8BD/5uxMXdg53A/4DLXTdwP2iqx9iw6diA8=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 buname.py $out/opt/buname.py
    makeWrapper ${lib.getExe python3} $out/bin/buname \
      --add-flags "$out/opt/buname.py"

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/dramforever/buname";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Uname wrapper that renumbers Linux versions as if 2.6 never ended";
    homepage = "https://github.com/dramforever/buname";
    license = lib.licenses.unfree;
    mainProgram = "buname";
    platforms = lib.platforms.linux;
  };
})
