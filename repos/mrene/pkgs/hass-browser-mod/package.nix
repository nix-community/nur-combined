{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "hass-browser-mod";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-browser_mod";
    rev = "v${version}";
    hash = "sha256-thirjQ5YJS8e8uIhDGQ9cTNLhH3LJwJWrxrMTZaxcXw=";
  };

  npmDepsHash = "sha256-/rA+BX+B2erJs0lC3CcMTxV1D8BX3FhNCAZaC7gNsbo=";

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
