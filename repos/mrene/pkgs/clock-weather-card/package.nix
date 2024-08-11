{ lib
, fetchFromGitHub
, mkYarnPackage
, fetchYarnDeps
}:

mkYarnPackage rec {
  pname = "clock-weather-card";
  version = "2.8.3";

  src = fetchFromGitHub {
    owner = "pkissling";
    repo = "clock-weather-card";
    rev = "v${version}";
    hash = "sha256-Qcem4ixSzBHah8WbAwaieB3GgurWSo9y5Ty2Yvx/mGU=";
  };

  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-hu1AVAfnr9K4Bv8tHE/HWSTg+ZrWEf+MldRodqv8zTU=";
  };

  buildPhase = ''
    runHook preBuild

    yarn build
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./deps/clock-weather-card/dist/clock-weather-card.js $out/

    runHook postInstall
  '';

  doDist = false;

  meta = with lib; {
    description = "A Home Assistant Card indicating today's date/time, along with an iOS inspired weather forecast for the next days with animated icons";
    homepage = "https://github.com/pkissling/clock-weather-card";
    changelog = "https://github.com/pkissling/clock-weather-card/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "clock-weather-card";
    platforms = platforms.linux;
  };
}
