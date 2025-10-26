{ lib
, stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "hass-browser-mod";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-Csbs7ikiBogpHC2kpGn/xydU68E4gGt3bL8sWCSP83A=";
  };

  npmDepsHash = "sha256-JIZ2R3XbXT9Ts+Eio7LTb/kbQpcvXIhTOw0R8wNqhpw=";

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
