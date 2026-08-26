{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clock-weather-card";
  version = "2.9.4";

  src = fetchFromGitHub {
    owner = "pkissling";
    repo = "clock-weather-card";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lqJF4Hql2uZmVRldcfsHiykFVUiudjfr4xrnERwkI+s=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-nXgqGQfnTLYy24iqz6VnHTpys1RA9vYbpDzlCsj1OPg=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp dist/clock-weather-card.js $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Home Assistant Card indicating today's date/time, along with an iOS inspired weather forecast for the next days with animated icons";
    homepage = "https://github.com/pkissling/clock-weather-card";
    changelog = "https://github.com/pkissling/clock-weather-card/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    platforms = platforms.linux;
  };
})
