{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "hass-browser-mod";
  version = "2.13.3";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-Q7+9pcV9vZ+PPXjlOezcDPtzcekXqBHgPJSwh5n9ruE=";
  };

  npmDepsHash = "sha256-MeB1NgQM8HvQF42AaE1XkIt0aODVACO8a0wtUFOqVW8=";

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
