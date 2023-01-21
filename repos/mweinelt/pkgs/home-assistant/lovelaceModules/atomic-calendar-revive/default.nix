{ lib
, fetchFromGitHub
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "atomic-calendar-revive";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "totaldebug";
    repo = "atomic-calendar-revive";
    rev = "refs/tags/v${version}";
    hash = "sha256-RHkSbvrtgBBbu817JEh0u1kNmapn8AoCJkm4Q+xuARM=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preCheck

    mkdir -vp $out
    cp -v dist/atomic-calendar-revive.js $out/

    runHook postCheck
  '';

  meta = with lib; {
    changelog = "https://github.com/totaldebug/atomic-calendar-revive/releases/tag/v${version}";
    description = "An advanced calendar card for Home Assistant Lovelace";
    homepage = "https://github.com/totaldebug/atomic-calendar-revive";
    license = licenses.mit;
  };
}