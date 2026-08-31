{
  fetchFromGitHub,
  unstableGitUpdater,
  lib,
  stdenv,
  python3,
  makeWrapper,
  runCommand,
  chromium,
  xorgserver,
  undetected-chromedriver,
  ...
}:
let
  python = python3.withPackages (
    p: with p; [
      bottle
      waitress
      selenium
      func-timeout
      psutil
      prometheus-client
      requests
      certifi
      packaging
      websockets
      deprecated
      mss
      xvfbwrapper
      distutils
      drissionpage
    ]
  );

  chromium-wrapped = runCommand "chromium-wrapped" { nativeBuildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper \
      ${chromium}/bin/chromium \
      $out/bin/chromium \
      --add-flags "--disable-gpu"
  '';

  path = lib.makeBinPath [
    chromium-wrapped
    undetected-chromedriver
    xorgserver
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flaresolverr-alexfozor";
  version = "0-unstable-2024-07-20";
  src = fetchFromGitHub {
    owner = "AlexFozor";
    repo = "FlareSolverr";
    rev = "eb680efc9059ef08907aaec58340d73325048aeb";
    hash = "sha256-6szzcqvDuJX8YIC5rhdpb7XbAjM6IMrivVtHpzIl5gc=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/

    makeWrapper ${python}/bin/python $out/bin/flaresolverr \
      --add-flags "$out/opt/src/flaresolverr.py" \
      --set PATH "${path}"

    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = "flaresolverr";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Proxy server to bypass Cloudflare protection, with AlexFozor modifications to support Drission Page";
    homepage = "https://github.com/AlexFozor/FlareSolverr";
    license = licenses.mit;
  };

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/AlexFozor/FlareSolverr";
    hardcodeZeroVersion = true;
  };
})
