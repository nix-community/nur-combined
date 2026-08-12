{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update,
  writeShellScript,
}:
stdenvNoCC.mkDerivation {
  pname = "hass-garmin-connect";
  version = "3.0.15-unstable-2026-08-11";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "home-assistant-garmin_connect";
    rev = "22b0889b44174c94e4d43b4268cffed2c38c6b08";
    hash = "sha256-hX+8rUhDFIpnd3l1sproYxuASPxMw3haRHphywUPC24=";
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
