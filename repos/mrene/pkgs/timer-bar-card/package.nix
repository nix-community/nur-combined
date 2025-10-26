{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage
}:

buildNpmPackage rec {
  pname = "timer-bar-card";
  version = "1.31.1";

  src = fetchFromGitHub {
    owner = "rianadon";
    repo = "timer-bar-card";
    rev = "939b0e4d392b1e5cc1d62ca0eafc339717c6d170";
    hash = "sha256-kuitsCu+Evv8sHUC8WOLu1FfvrSigMUZEipkEqbX5K8=";
  };

  prePatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-mFl4dQFKOMD69AX8S1iyFw1gK63CXbExdNOxileFlcs=";
  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp ./dist/timer-bar-card.js $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A progress bar display for Home Assistant timers";
    homepage = "https://github.com/rianadon/timer-bar-card";
    license = licenses.asl20;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "timer-bar-card";
    platforms = platforms.all;
  };
}
