{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "hass-browser-mod";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-OOMbMQkDC1eeljtu8UiY+YkenDIWReXNAfjoo64E2Rs=";
  };

  npmDepsHash = "sha256-iwaECS2y7PWrPbeZMq2gsF4ixQFOQLIklLKRCRtwT9U=";

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp custom_components/browser_mod/browser_mod.js $out/
    cp custom_components/browser_mod/browser_mod_browser_panel.js $out/
    cp custom_components/browser_mod/browser_mod_config_panel.js $out/

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
