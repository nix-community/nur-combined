{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "hass-browser-mod";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-JqbMgpXstUcQwLXPbIRtcg1OqNZycA0CFRW7G5G7eA8=";
  };

  npmDepsHash = "sha256-6Ax3nw4VjlS7e4cyN6FawLDP6lfVEk8hjahN26IQo5I=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp custom_components/browser_mod/browser_mod.js $out/
    cp custom_components/browser_mod/browser_mod_panel.js $out/

    runHook postInstall
  '';

  passthru = {
    entrypoint = "browser_mod.js";
  };

  meta = with lib; {
    description = "A Home Assistant integration to turn your browser into a controllable entity and media player";
    homepage = "https://github.com/thomasloven/hass-browser_mod";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "hass-browser-mod";
    platforms = platforms.linux;
  };
}
