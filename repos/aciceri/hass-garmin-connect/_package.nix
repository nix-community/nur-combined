{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update,
  writeShellScript,
}:
stdenvNoCC.mkDerivation {
  pname = "hass-garmin-connect";
  version = "3.0.14-unstable-2026-08-09";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "home-assistant-garmin_connect";
    rev = "c848bcb87bacd34355142a2365c191fe6b41775b";
    hash = "sha256-h8aXheDnfXFgz5c3ZeXAccUQi7InKhiiSj1Ni65zwS4=";
  };

  # Home Assistant consumes this as a raw source tree: the config dir gets
  # `custom_components/garmin_connect` copied in by a tmpfiles rule, so the
  # runtime dependencies are resolved by the Home Assistant python env itself.
  # buildHomeAssistantComponent would only pull that whole env in for nothing.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r custom_components $out/
    runHook postInstall
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake hass-garmin-connect --version=branch";

  meta = {
    description = "Home Assistant integration exposing and uploading Garmin Connect data";
    homepage = "https://github.com/cyberjunky/home-assistant-garmin_connect";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
